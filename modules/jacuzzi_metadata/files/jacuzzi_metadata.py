#!/usr/bin/env python
"""
Populates a file (e.g. /etc/jacuzzi_data.json) with information about what
jacuzzis (if any) this machine is in

Usage:
    jacuzzi_metadata.py [-o output_file]

Options:
    -o output_file  Output to output_file rather than stdout """
import urllib2
import json
import urlparse
import logging
import time
import os

log = logging.getLogger(__name__)

JACUZZI_URL = "http://jacuzzi-allocator.pub.build.mozilla.org/v1/machines/"


def get_jacuzzi_metadata(machine):
    url = urlparse.urljoin(JACUZZI_URL, machine)
    max_tries = 3
    for _ in range(max_tries):
        log.debug("Fetching %s", url)
        try:
            return json.load(urllib2.urlopen(url, timeout=1))
        except urllib2.HTTPError, e:
            if e.code == 404:
                log.debug("couldn't find data for %s, returning None", url)
                return None
            if _ < max_tries - 1:
                log.debug("failed to fetch %s; sleeping and retrying", url, exc_info=True)
                time.sleep(1)
                continue
            return None


def main():
    from optparse import OptionParser
    parser = OptionParser(__doc__)
    parser.set_defaults(
        logdevel=logging.INFO,
    )
    parser.add_option("-v", "--verbose", help="verbose logging", dest="loglevel", const=logging.DEBUG, action="store_const")
    parser.add_option("-o", dest="output_file")
    options, args = parser.parse_args()

    logging.basicConfig(level=options.loglevel)

    hostname = os.uname()[1].split(".")[0]
    metadata = get_jacuzzi_metadata(hostname)
    js = json.dumps(metadata)

    # If output_file is -, treat that as stdout
    if options.output_file == '-':
        options.output_file = None

    if options.output_file is None:
        print js
    else:
        # Write to a tmpfile first
        import tempfile
        fd, tmpname = tempfile.mkstemp(
            dir=os.path.dirname(options.output_file),
            prefix=os.path.basename(options.output_file))
        try:
            os.write(fd, js)
            os.close(fd)
            # Then rename to our final file
            os.rename(tmpname, options.output_file)
        except Exception:
            log.exception("error writing json, trying to clean up temporary file")
            os.unlink(tmpname)


if __name__ == '__main__':
    main()
