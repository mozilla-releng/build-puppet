#!/usr/bin/env python

'''
Decide whether or not to halt runner based on slave data.
'''

import re
import sys
import json
import socket
import urllib2

BUILD_API_URL_BASE = 'http://buildapi.pvt.build.mozilla.org/buildapi/recent/'
BUILD_API_URL_SUFFIX = '?format=json&numbuilds=1'

socket.setdefaulttimeout(12)  # applies to all API requests


def get_hostname():
    return socket.gethostname().split('.')[0]


def get_recent_builds(slavename):
    url = '%s%s%s' % (BUILD_API_URL_BASE, slavename, BUILD_API_URL_SUFFIX)
    request = urllib2.Request(url)
    results = urllib2.urlopen(request)
    processed_results = json.loads(results.read())
    return processed_results


def halt():
    '''
    return code 2 to coerce runner to run its halt task.
    '''
    sys.exit(2)


def get_hostname_blacklist():
    '''
    A list of hostname expressions which will coerce a halt.
    '''
    # blacklist test, talos, and try
    return ['^t.*', '^t.*lion.*', '^t.*snow.*', '^t.*yosemite.*', '^t.*mavericks.*']


def is_blacklisted(entry, blacklist):
    '''
    compare some entry to a list of blacklist expressions, return False
    by default or True if any match.
    '''
    return any(re.match(expression, entry) for expression in blacklist)


if __name__ == '__main__':
    hostname = get_hostname()

    if is_blacklisted(hostname, get_hostname_blacklist()):
        print('Hostname is blacklisted: halting')
        halt()

    build_data = get_recent_builds(hostname)
    print('Got build data: %s' % build_data)

    if not build_data:
        # The exception should coerce a retry
        raise Exception('Failed to find data for %s' % hostname)
    if build_data[0]['result'] != 0:
        print('Last job failed: halting')
        halt()
