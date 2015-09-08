#!/usr/bin/env python
# Check that we're running an up-to-date AMI

import time
import urllib2
import json
import urlparse
import yaml
import os
import logging
import random

AWS_METADATA_URL = "http://169.254.169.254/latest/meta-data/"
AWS_USERDATA_URL = "http://169.254.169.254/latest/user-data"
URL = "https://s3.amazonaws.com/mozilla-releng-amis/amis.json"
AMI_TTL = 3 * 60 * 60  # 3 hours

log = logging.getLogger(__name__)


def should_recycle(created, ttl):
    """Decide if should recycle increasing probability depending on how close
    to TTL."""
    return random.random() + (time.time() - created) / float(ttl) > 1


def get_page(url):
    max_tries = 3
    for _ in range(max_tries):
        try:
            return urllib2.urlopen(url, timeout=1).read()
        except urllib2.URLError:
            if _ < max_tries - 1:
                time.sleep(1)
                continue
            return None


def get_aws_metadata(key=None):
    """Gets values form AWS_METADATA_URL"""
    url = urlparse.urljoin(AWS_METADATA_URL, key)
    return get_page(url)


def get_aws_userdata():
    """Gets AWS user-data"""
    user_data = get_page(AWS_USERDATA_URL)
    try:
        return yaml.safe_load(user_data)
    except Exception:
        return None


def is_aws_instance():
    return get_aws_metadata() is not None


def get_json(url):
    try:
        return json.loads(get_page(url))
    except Exception:
        return None


def get_compatible_amis(amis, az, moz_instance_type):
    """Filter AMIs using moz-type tag and regions, sorting by moz-created"""
    return sorted([a for a in amis.values() if
                   a["tags"].get("moz-type") == moz_instance_type and
                   a["region"] in az],  # us-west-2 in us-west-2d
                  key=lambda e: (e.get("tags", {}).get("moz-created"),
                                 e.get("id")), reverse=True)


def main():
    my_ami = get_aws_metadata("ami-id")
    az = get_aws_metadata("placement/availability-zone")
    user_data = get_aws_userdata()
    if not user_data:
        log.error("cannot operate without userdata")
        exit(1)
    moz_instance_type = user_data["moz_instance_type"]
    amis = get_json(URL)
    compatible_amis = get_compatible_amis(amis, az, moz_instance_type)
    if not compatible_amis:
        log.warn("no compatible AMIs found, skipping")
        exit(0)
    last_ami = compatible_amis[0]
    if my_ami != last_ami["id"]:
        created = int(last_ami["tags"]["moz-created"])
        if should_recycle(created, AMI_TTL):
            log.warn("Time to recycle!")
            os.system("/sbin/poweroff")

if __name__ == "__main__":
    logging.basicConfig(format="%(message)s", level=logging.INFO)
    if not is_aws_instance():
        log.warn("Not an AWS instance, skipping")
        exit(0)
    else:
        main()
