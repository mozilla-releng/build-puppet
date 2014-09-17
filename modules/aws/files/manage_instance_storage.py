#!/usr/bin/env python
"""Manages the instance storage space for aws instances"""

import logging
import os
import urllib2
import urlparse
import time
from subprocess import check_call, CalledProcessError, Popen, PIPE


log = logging.getLogger(__name__)

AWS_METADATA_URL = "http://169.254.169.254/latest/meta-data/"


def get_aws_metadata(key):
    """Gets values form AWS_METADATA_URL"""
    url = urlparse.urljoin(AWS_METADATA_URL, key)
    max_tries = 3
    for _ in range(max_tries):
        log.debug("Fetching %s", url)
        try:
            return urllib2.urlopen(url, timeout=1).read()
        except urllib2.URLError:
            if _ < max_tries - 1:
                log.debug("failed to fetch %s; sleeping and retrying", url)
                time.sleep(1)
                continue
            return None


def run_cmd(cmd, cwd=None, raise_on_error=True, quiet=True):
    """A subprocess wrapper"""
    if not cwd:
        cwd = os.getcwd()
    log.debug("Running: %s cwd: %s", cmd, cwd)
    stdout = None
    stderr = open(os.devnull, 'w')
    if log.level == logging.DEBUG:
        # enable stderr only when we are in DEBUG mode
        stderr = None
    if quiet:
        stdout = open(os.devnull, 'w')
    try:
        check_call(cmd, cwd=cwd, stdout=stdout, stderr=stderr)
        return True
    except CalledProcessError:
        if raise_on_error:
            raise
        return False


def get_output_from_cmd(cmd, cwd=None, raise_on_error=True):
    """A subprocess wrapper that returns the stdout"""
    # note this is a simple wrapper, do not try to run this function
    # if command produces a lot of output.
    if not cwd:
        cwd = os.getcwd()
    log.debug("Running %s cwd: %s", cmd, cwd)
    # check_output is not avalilable in prod (python 2.6)
    # return check_output(cmd, cwd=cwd, stderr=None).splitlines()
    proc = Popen(cmd, cwd=cwd, stdout=PIPE)
    output, err = proc.communicate()
    retcode = proc.poll()
    if retcode and raise_on_error:
        log.debug('cmd: %s returned %s (%s)', cmd, retcode, err)
        raise CalledProcessError(retcode, cmd)
    return output


def get_ephemeral_devices():
    """Gets the list of ephemeral devices"""
    block_devices_mapping = get_aws_metadata("block-device-mapping/")
    if not block_devices_mapping:
        return []
    block_devices = block_devices_mapping.split("\n")
    names = [b for b in block_devices if b.startswith("ephemeral")]
    retval = []
    for name in names:
        device = get_aws_metadata("block-device-mapping/%s" % name)
        device = "/dev/%s" % device
        if not os.path.exists(device):
            device = aws2xen(device)
        if os.path.exists(device):
            retval.append(device)
        else:
            log.warn("%s doesn't exist", device)
    return retval


def aws2xen(device):
    """"Converts AWS device names (e.g. /dev/sdb)
    to xen block device names (e.g. /dev/xvdb)"""
    return device.replace("/s", "/xv")


def needs_pvcreate(device):
    """Checks if pvcreate is needed"""
    output = get_output_from_cmd('pvs')
    log.debug("pvs output for device %s: %s ", device, output)
    for line in output.splitlines():
        if device in line:
            return False
    return True


def _query_vgs(token, device=None):
    """Gets token value from vgs -o token device"""
    cmd = ['vgs', '--noheadings', '-o', token]
    if device:
        cmd.append(device)
    try:
        value = get_output_from_cmd(cmd)
        value = value.splitlines()[0].strip()
        log.debug('vgs: %s = %s', token, value)
        return value
    except (CalledProcessError, IndexError):
        # vgs command failed, no volume groups
        log.debug('No %s for device %s', token, device)
        return None


def query_lv_path(device=None):
    """Returns the ouptut of vgs -o lv_path <device>"""
    return _query_vgs(token='lv_path', device=device)


def query_vg_name(device=None):
    """Checks if vg already exists and returns its name.
       returns None if there are no vg"""
    return _query_vgs(token='vg_name', device=device)


def pvcreate(device):
    """Wrapper for pvcreate, determines if physical device needs initialization
       and manages cases where a physical device is already mounted"""
    if needs_pvcreate(device):
        log.info('running pvcreate on: %s', device)
        log.debug('clearing the partition table for %s', device)
        run_cmd(['dd', 'if=/dev/zero', 'of=%s' % device, 'bs=512', 'count=1'])
        log.debug('creating a new physical volume for: %s', device)
        run_cmd(['pvcreate', '-ff', '-y', device])


def main():
    """Prepares the ephemeral devices"""
    logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)
    devices = get_ephemeral_devices()
    if not devices:
        # no ephemeral devices, nothing to do, quit
        log.info('no ephemeral devices found')
        return
    devices = [d for d in devices if needs_pvcreate(d)]
    if not devices:
        log.info('Ephemeral devices already in LVM')
        return

    root_vg = query_vg_name()
    root_lv = query_lv_path()
    for dev in devices:
        pvcreate(dev)
        run_cmd(["vgextend", root_vg, dev])

    run_cmd(["lvextend", "-l", "100%FREE", root_lv])
    run_cmd(["resize2fs", root_lv])


if __name__ == '__main__':
    main()
