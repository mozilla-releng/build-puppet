#!/usr/bin/env python
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

'''
Convert json strings into influxdb submissions along with host data.
    Usage: influxdb_hook.py <stats_json> <name> <url>
    Run tests: python -m doctest -v influxdb_hook.py
'''

import re
import sys
import json
import socket
import urllib2

socket.setdefaulttimeout(12)


def get_recent_builds(twistd_log):
    '''
    Scrape a buildbot twistd log for builds which have run on this machine.
    Note: Unfortunately this function has been copied from the post_flight hook,
    this hook, along with all runner tasks, should be made into a python package
    so that this can be avoided.
    '''
    all_builds = []
    with open(twistd_log, 'r') as log:
        for line in log:
            match = re.search(r'.*\((.*)\).*message from master: ping', line)
            if match:
                all_builds.append(match.group(1))
    return all_builds


def dumps_plus_args(json_string, **kwargs):
    '''
    Combine a json string and keyword arguments into a single dict.
    >>> dumps_plus_args('{"a": 1}', **{u'b': 2})
    {u'a': 1, u'b': 2}
    '''
    processed_json = json.loads(json_string)
    if not isinstance(processed_json, dict):
        raise Exception("dumps_plus_args only works with json dictionaries")
    processed_json.update(kwargs)
    return processed_json


def dict_to_influxdb_stats(name, stats_dict):
    '''
    Serialize a stats dict into a json string format which is usable by
    influxdb.
    >>> p = dict_to_influxdb_stats('f', {'b': 9, 'x': 'y'})
    >>> json.loads(p)[0] == {u'points': [[u'y', 9]], u'name': u'f', u'columns': [u'x', u'b']}
    True
    '''
    raw_dict = dict(name=name, columns=[], points=[[]])
    for k, v in stats_dict.items():
        raw_dict['columns'].append(k)
        raw_dict['points'][0].append(v)
    return json.dumps([raw_dict])


def submit_stats(url, stats):
    '''Submit to influxdb with a simple http post.'''
    # the influxdb url should have a username/password attached to it, which
    # we'll strip off and add to a BasicAuth header instead of passing them
    # in a GET
    url = url.split('?')
    data = url[1].split('&')
    username = data[0].split('u=')[1]
    password = data[1].split('p=')[1]
    passman = urllib2.HTTPPasswordMgrWithDefaultRealm()
    passman.add_password(None, url[0], username, password)
    authhandler = urllib2.HTTPBasicAuthHandler(passman)
    opener = urllib2.build_opener(authhandler)
    urllib2.install_opener(opener)
    result = urllib2.urlopen(url[0], stats)
    if result.code != 200:
        raise Exception('Stat submission to %s failed: HTTP RESPONSE %i' % (url, result.code))


if __name__ == '__main__':
    import os

    try:
        stats = sys.argv[1]
        cred_file = os.path.join(
            os.path.dirname(os.path.abspath(__file__)), '.influxcreds')
        if os.path.exists(cred_file):
            url, name = open(cred_file, 'r').read().strip().split('|')
        else:
            name = os.environ.get('INFLUXDB_NAME') or sys.argv[2]
            url = os.environ.get('INFLUXDB_URL') or sys.argv[3]
    except IndexError:
        print('Usage: influxdb_hook.py <stats_json> <name> <url>')
        sys.exit(0)

    # Make sure we don't kill runner due to a failing hook
    instance_metadata = {}
    try:
        with open("/etc/instance_metadata.json") as metadata:
            instance_metadata = json.loads(metadata.read())
    except:
        pass

    log_path = os.environ.get('TWISTD_LOG_PATH', '/builds/slave/twistd.log')
    log_path_retry = log_path + '.1'

    build_data = []
    try:
        build_data = get_recent_builds(log_path)
        # In the case that logs were just rotated, we will find no data.
        # So, try to fetch data from the most recently rotated log (logname + '.1')
        if not build_data:
            build_data = get_recent_builds(log_path_retry)
    except IOError:
        print("No twistd long found, can't find last_build_name")

    last_build_name = None if len(build_data) <= 0 else build_data[-1]

    try:
        stats_dict = dumps_plus_args(
            stats,
            platform=sys.platform,
            hostname=socket.gethostname(),
            last_build_name=last_build_name,
            **instance_metadata
        )
        stats_json = dict_to_influxdb_stats(name, stats_dict)
        submit_stats(url, stats_json)
    except Exception as e:
        print("%s failed: %s" % (__file__, e))
