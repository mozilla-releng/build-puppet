#!/usr/bin/env python
"""
Populates a file (e.g. /etc/instance_data.json) with instance metadata

Usage:
    instance_metadata.py [-o output_file]

Options:
    -o output_file  Output to output_file rather than stdout """
import urllib2
import json
import urlparse
import logging
import time
import os

log = logging.getLogger(__name__)

AWS_METADATA_URL = "http://169.254.169.254/latest/meta-data/"


def get_aws_metadata(key):
    url = urlparse.urljoin(AWS_METADATA_URL, key)
    max_tries = 3
    for _ in range(max_tries):
        log.debug("Fetching %s", url)
        try:
            return urllib2.urlopen(url, timeout=1).read()
        except urllib2.URLError:
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

    metadata = {
        "aws_instance_id": get_aws_metadata("instance-id"),
        "aws_instance_type": get_aws_metadata("instance-type"),
        "aws_ami_id": get_aws_metadata("ami-id"),
    }
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
