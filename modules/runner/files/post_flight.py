#!/usr/bin/env python

'''
Decide whether or not to halt runner based on slave data.
'''

import re
import os
import sys
import socket

BUILD_API_URL_BASE = 'http://buildapi.pvt.build.mozilla.org/buildapi/recent/'
BUILD_API_URL_SUFFIX = '?format=json&numbuilds=1'

socket.setdefaulttimeout(12)  # applies to all API requests


def get_hostname():
    return socket.gethostname().split('.')[0]


def get_recent_builds(twistd_log):
    '''
    Scrape a buildbot twistd log for builds which have run on this machine.
    '''
    all_builds = []
    with open(twistd_log, 'r') as log:
        for line in log:
            match = re.search(r'.*\((.*)\).*message from master: ping', line)
            if match:
                all_builds.append(match.group(1))
    return all_builds


def halt():
    '''
    return code 2 to coerce runner to run its halt task.
    '''
    sys.exit(2)


def get_hostname_blacklist():
    '''
    A list of hostname expressions which will coerce a halt.
    '''
    return []


def get_buildname_blacklist():
    '''
    A list of build name expressions which will coerce a halt, names are
    retrieved from buildapi via get_recent_builds().
    '''
    # reboot after android, b2g emulator, reftest, or mochitest jobs
    return ['.*android.*', '.*emulator.*', '.*mochi.*', '.*reftest.*']


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

    build_data = None
    log_path = os.environ.get('TWISTD_LOG_PATH', '/builds/slave/twistd.log')
    log_path_retry = log_path + '.1'

    try:
        build_data = get_recent_builds(log_path)
    except IOError:
        print('%s not found, trying: %s' % (log_path, log_path_retry))
    # In the case that logs were just rotated, we will find no data.
    # So, try to fetch data from the most recently rotated log (logname + '.1')
    if not build_data:
        build_data = get_recent_builds(log_path_retry)

    if not build_data:
        print('No recent builds found: halting')
        halt()
    elif is_blacklisted(build_data[-1], get_buildname_blacklist()):
        print('Buildname is blacklisted: halting')
        halt()
