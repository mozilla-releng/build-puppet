#!/usr/bin/env python
import requests
import hashlib
import tempfile
from mardor.marfile import BZ2MarFile
import shutil
import ConfigParser
from functools import partial
import os
import json
from zipfile import ZipFile
import logging
from argparse import ArgumentParser
log = logging.getLogger(__name__)

CONFIGS = []
ARIES_CONFIG = dict(namespace='gecko.v2.mozilla-central.latest.b2g.aries-ota-opt',
                    artifact='public/build/b2g-aries-gecko-update.mar',
                    product='B2G',
                    release='B2G-nightly-latest',
                    platform='aries',
                    locale='en-US',
                    balrog_username='stage-b2gbld',  # TODO - use production username
                    schema_version=4)
B2GDROID_CONFIG = dict(namespace='gecko.v2.mozilla-central.latest.mobile.android-api-11-b2gdroid-opt',
                       artifact='public/build/target.apk',
                       product='B2GDroid',
                       branch='mozilla-central',
                       # same as all android build_platforms
                       platform='Android_arm-eabi-gcc3',
                       locale='en-US',
                       balrog_username='ffxbld',
                       schema_version=4)

# TODO - append aries config
CONFIGS.append(B2GDROID_CONFIG)

BALROG_API_ROOT = 'https://aus4-admin.mozilla.org/api'


def sha512sum(filename):
    h = hashlib.new('sha512')
    with open(filename, 'rb') as f:
        for block in iter(partial(f.read, 1024**2), b''):
            h.update(block)
        return h.hexdigest()


def get_info_from_ini(ini_path, archive_path, archive):
    """
    extracts and returns info from an ini file
    :param ini_path: path to ini
    :param archive_path: path to archive (e.g. apk or mar archive)
    :param archive: the archive object itself
    :return: dict containing platformVersion, appVersion, displayVersion, buildID, and completes
    """
    # Extract it!
    complete_info = {
        'from': '*',
        'hashValue': sha512sum(archive_path),
        'filesize': os.path.getsize(archive_path),
    }
    retval = {'completes': [complete_info]}
    tmpdir = tempfile.mkdtemp()

    try:
        ini = archive.extract(ini_path, tmpdir)
        conf = ConfigParser.RawConfigParser()
        conf.read([ini])
        if ini_path.filename == 'platform.ini':
            retval['platformVersion'] = conf.get('Build', 'Milestone')
        else:
            retval['appVersion'] = conf.get('App', 'Version')
            retval['displayVersion'] = conf.get('App', 'Version')
            retval['buildID'] = conf.get('App', 'BuildID')
    finally:
        shutil.rmtree(tmpdir)
    return retval


def get_mar_info(archive_path):
    mar = BZ2MarFile(archive_path)
    retval = {}

    for m in mar.members:
        if m.name.endswith("platform.ini") or m.name.endswith("application.ini"):
            retval.update(get_info_from_ini(m, archive_path, mar))

    return retval


def get_apk_info(archive_path):
    apk = ZipFile(archive_path)
    retval = {}

    for z in apk.infolist():
        if z.filename.endswith("platform.ini") or z.filename.endswith("application.ini"):
            retval.update(get_info_from_ini(z, archive_path, apk))

    return retval


def get_file_info(url):
    s = 0
    r = requests.get(url, stream=True)
    expected_size = int(r.headers['Content-Length'])
    with tempfile.NamedTemporaryFile() as tmp:
        for block in r.iter_content(1024**2):
            s += len(block)
            tmp.write(block)
        tmp.flush()
        assert expected_size == s

        if url.endswith(".mar"):
            info = get_mar_info(tmp.name)
            info['completes'][0]['fileUrl'] = url
            return info
        elif url.endswith(".apk"):
            info = get_apk_info(tmp.name)
            info['completes'][0]['fileUrl'] = url
            return info


class TCIndex:
    api_root = 'https://index.taskcluster.net/v1'

    def get_artifact_url(self, namespace, filename):
        url = '{}/task/{}/artifacts/{}'.format(self.api_root, namespace, filename)
        return requests.get(url, allow_redirects=False).headers['Location']


class Balrog:
    auth = ()

    def get_auth(self, username, auth_file=None):
        if self.auth:
            return self.auth

        if not os.path.exists(auth_file):
            log.error(
                'Could not determine path to balrog credentials. Does "{}" exist?'.format(auth_file)
            )

        credentials = {}
        execfile(auth_file, credentials)
        self.auth = (username, credentials['balrog_credentials'][username])
        return self.auth

    def update_release(self, product, schema_version, api, info,
                       balrog_username, auth_file, ca_cert):
        # needed to preserve cookie so csrf works
        session = requests.session()

        data = {
            'product': product,
            'version': info['appVersion'],
            'hashFunction': 'sha512',
            'schema_version': schema_version,
        }
        data['data'] = json.dumps(info)

        # Get the old release - we need the old data_version and csrf token
        resp = session.head(api, auth=self.get_auth(balrog_username, auth_file), verify=ca_cert)
        if resp.status_code == 200:
            log.info('previous release found; updating')
            data['data_version'] = resp.headers['X-Data-Version']
            data['csrf_token'] = resp.headers['X-CSRF-Token']
        elif resp.status_code == 404:
            log.info('previous release not found; creating a new one')
            # Get a new csrf token
            resp = session.head("{}/csrf_token".format(BALROG_API_ROOT),
                                auth=self.get_auth(balrog_username, auth_file), verify=ca_cert)
            resp.raise_for_status()
            data['csrf_token'] = resp.headers['X-CSRF-Token']
        else:
            resp.raise_for_status()

        resp = session.put(api, auth=self.get_auth(balrog_username, auth_file),
                           data=data, verify=ca_cert)
        resp.raise_for_status()


def load_cache(filename=None):
    if not filename:
        filename = 'cache.json'
    try:
        return json.load(open(filename))
    except IOError:
        return {}


def save_cache(cache, filename=None):
    if not filename:
        filename = 'cache.json'
    with open(filename, 'w') as f:
        json.dump(cache, f, indent=2)


def main(args):
    logging.basicConfig(level=logging.INFO, format="%(asctime)s - %(message)s",
                        filename=args.log_file)
    balrog = Balrog()
    index = TCIndex()

    log.info('loading cache')
    cache = load_cache(filename=args.cache_file)
    log.debug('cache: %s', cache)

    for c in CONFIGS:
        log.info('finding latest %s %s', c['namespace'], c['artifact'])
        try:
            url = index.get_artifact_url(c['namespace'], c['artifact'])
        except Exception:
            log.exception('could not download latest complete artifact')
            raise
        log.info('got url: %s', url)
        cache_key = '{c[namespace]}:{c[artifact]}'.format(c=c)
        if cache.get(cache_key) == url:
            log.info('unchanged url; skipping')
            continue
        cache[cache_key] = url
        log.info('downloading...')
        info = get_file_info(url)

        log.info('updating balrog: %s', info)
        # submit this release then update 'latest' channel to point to it
        for blob in [info['buildID'], 'latest']:
            api = '{}/releases/{}-{}-nightly-{}/builds/{}/{}'.format(
                BALROG_API_ROOT, c['product'], c['branch'], blob, c['platform'], c['locale']
            )
            try:
                balrog.update_release(c['product'], c['schema_version'], api, info,
                                      c['balrog_username'], args.auth_file, args.ca_cert)
            except Exception:
                log.exception('could not submit release blob to: {}'.format(api))
                raise

    log.info('saving cache')
    log.debug('cache: %s', cache)
    save_cache(cache, args.cache_file)

if __name__ == '__main__':
    parser = ArgumentParser(description='Looks for latest completed continuous integration '
                                        'build from a product and promotes it to a nightly by '
                                        'submitting build info to update server, Balrog')
    parser.add_argument('auth_file', help='path to update server credentials')
    parser.add_argument('ca_cert', help='path to ca_cert')
    parser.add_argument('--log-file', help='path of log file', default='nightly-promotion.log')
    parser.add_argument('--cache-file', help='path to cache of most recently promoted '
                                             'continuous integration taskcluster job',
                        default='cache.json')
    args = parser.parse_args()

    main(args)

