#!/usr/bin/env python
"""Manages the instance storage space for aws instances
   For try, jacuzzi and instances with more than REQ_BUILDS_SIZE,
   the instance storage space is mounted under BUILDS_SLAVE_MNT,
   In any other case, the instance storage space is mounted under
   INSTANCE_STORAGE_MNT.
   CCACHE_DIR is always mounted on the instance storage
"""

import errno
import logging
import json
import os
import urllib2
import urlparse
import time
from subprocess import check_call, CalledProcessError, Popen, PIPE


log = logging.getLogger(__name__)

AWS_METADATA_URL = "http://169.254.169.254/latest/meta-data/"
INSTANCE_STORAGE_MNT = '/mnt/instance_storage'
BUILDS_SLAVE_MNT = '/builds/slave'
JACUZZI_METADATA_JSON = '/etc/jacuzzi_metadata.json'
CCACHE_DIR = '/builds/ccache'
MOCK_DIR = '/builds/mock_mozilla'
ETC_FSTAB = '/etc/fstab'
REQ_BUILDS_SIZE = 120  # size in GB


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


def format_device(device):
    """Formats device with ext4 fs if needed"""
    if is_mounted(device):
        log.info('%s is mounted: skipping formatting', device)
        return
    # assuming this device needs to be formatted
    need_format = True
    blkid_cmd = ['blkid', '-o', 'udev', device]
    output = get_output_from_cmd(cmd=blkid_cmd, raise_on_error=False)
    if output:
        for line in output.splitlines():
            if 'ID_FS_TYPE=ext4' in line or \
               'ID_FS_TYPE=ext3' in line:
               # if the disk is already ext4 or ext3, do not format
                need_format = False
                log.info('%s no need to format: %s', device, line)
                break
    if need_format:
        log.info('formatting %s', device)
        run_cmd(['mkfs.ext4', device])


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
    cmd = ['vgs', '-o', token]
    if device:
        cmd.append(device)
    try:
        value = get_output_from_cmd(cmd)
        value = value.split('\n')[1].strip()
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


def vg_size(device=None):
    """Returns the size of device in GB, 0 in case of error"""
    raw_value = _query_vgs(token='vg_size', device=device)
    if not raw_value:
        return 0
    # raw_value: 79.98g to 80
    disk_size = int(round(float(raw_value.replace('g', ''))))
    log.debug('disk size: %s', disk_size)
    return int(round(float(raw_value.replace('g', ''))))


def create_vg(vg_name, devices):
    """Creates a volume group"""
    log.info('creating a new volume group, %s with %s', vg_name, devices)
    run_cmd(['vgcreate', vg_name] + devices)


def remove_vg(vg_name):
    """Removes a volume group"""
    if vg_name is None:
        log.debug('remove_vg: vg_name is None, nothing to do here')
    log.info('removing volume group: %s', vg_name)
    run_cmd(['vgremove', '-f', vg_name])


def pvcreate(device):
    """Wrapper for pvcreate, determines if physical device needs initialization
       and manages cases where a physical device is already mounted"""
    if needs_pvcreate(device):
        if is_mounted(device):
            # switching from a single disk instance to multiple disks
            # returns an error in pvcreate, let's umount the disk
            umount(CCACHE_DIR)
            umount(MOCK_DIR)
            remove_from_fstab(CCACHE_DIR)
            remove_from_fstab(MOCK_DIR)
            umount(device)
            remove_from_fstab(device)
        log.info('running pvcreate on: %s', device)
        log.debug('clearing the partition table for %s', device)
        run_cmd(['dd', 'if=/dev/zero', 'of=%s' % device, 'bs=512', 'count=1'])
        log.debug('creating a new physical volume for: %s', device)
        run_cmd(['pvcreate', '-ff', '-y', device])


def lvcreate(vg_name, lv_name, lv_path):
    """lvcreate wrapper"""
    lv_path = "/dev/mapper/%s-%s" % (vg_name, lv_name)
    if not run_cmd(['lvdisplay', lv_path], raise_on_error=False):
        log.info('creating a new logical volume')
        run_cmd(['lvcreate', '-l', '100%VG', '--name', lv_name, vg_name])
        format_device(lv_path)


def lvmjoin(devices):
    "Creates a single lvm volume from a list of block devices"
    for device in devices:
        pvcreate(device)
    # Volume Group
    vg_name = 'vg'
    lv_name = 'local'
    # old volume group
    old_vg = query_vg_name()
    if not old_vg:
        create_vg(vg_name, devices)
    elif old_vg != vg_name:
        # vg already exists with a different name;
        old_lv = query_lv_path()
        # maps output from vgs -> fstab_entry
        fstab_entry = is_dev_in_fstab(old_lv)
        if is_mounted(fstab_entry):
            disable_swap()
            umount(CCACHE_DIR)
            umount(MOCK_DIR)
            umount(fstab_entry)
        remove_from_fstab(old_vg)
        remove_vg(old_vg)
        create_vg(vg_name, devices)
    else:
        # a volume group with the same name already exists
        # output of vgs -
        disable_swap()
        umount(CCACHE_DIR)
        umount(MOCK_DIR)
        umount(query_lv_path())

    # Logical Volume
    lv_path = "/dev/mapper/%s-%s" % (vg_name, lv_name)
    lvcreate(vg_name, lv_name, lv_path)
    return lv_path


def fstab_line(device):
    """Check if device is in fstab"""
    is_fstab_line = False
    for line in read_fstab():
        if not line.startswith('#') \
           and device in line:
            log.debug("%s already in %s:", device.strip(), ETC_FSTAB)
            is_fstab_line = line
            break
    return is_fstab_line


def read_fstab():
    """"Returns a list of lines in fstab"""
    with open(ETC_FSTAB, 'r') as f_in:
        return f_in.readlines()


def remove_from_fstab(device):
    """Removes device from fstab"""
    old_fstab_line = fstab_line(device)
    if not old_fstab_line:
        log.debug('remove_from_fstab: %s is not in fstab', device)
        return
    import tempfile
    try:
        temp_fstab = tempfile.NamedTemporaryFile(delete=False)
        with open(temp_fstab.name, 'w') as out_fstab:
            for line in read_fstab():
                if old_fstab_line not in line:
                    out_fstab.write(line)
        log.info('removed %s from %s', old_fstab_line.strip(), ETC_FSTAB)
        os.rename(temp_fstab.name, ETC_FSTAB)
    except (OSError, IOError):
        # IOError => error opening temp_fstab
        # OSError => error renaming files
        log.debug('Unable to read/rename temporary fstab file')
        os.remove(temp_fstab.name)
        log.debug('deleted temporary file: %s', temp_fstab.name)


def append_to_fstab(device, mount_location, file_system, options, dump_freq,
                    pass_num):
    """Append device to fstab"""
    new_fstab_line = get_fstab_line(device, mount_location, file_system,
                                    options, dump_freq, pass_num)
    with open(ETC_FSTAB, 'a') as out_f:
        out_f.write(new_fstab_line)
    log.info('added %s in %s', new_fstab_line.strip(), ETC_FSTAB)


def get_fstab_line(device, mount_location, file_system, options, dump_freq,
                   pass_num):
    """Returns an entry for fstab"""
    # no matter if the disk is ext3 or ext4, just mount it as ext4
    # ext4 manages ext3 disks too
    # /dev/sda / ext4 defaults,noatime  1 1
    return '%s %s %s %s %d %d\n' % (device, mount_location, file_system,
                                    options, dump_freq, pass_num)


def update_fstab(device, mount_location, file_system, options, dump_freq,
                 pass_num):
    """Updates /etc/fstab if needed"""
    # example:
    # /dev/sda / ext4 defaults,noatime  0 0
    # /builds/slave/ccache /builds/ccache/ none bind,noatime 0 0
    new_fstab_line = get_fstab_line(device, mount_location, file_system,
                                    options, dump_freq, pass_num)
    old_fstab_line = fstab_line(device)
    if old_fstab_line == new_fstab_line:
        # nothing to do..
        log.debug('%s already in %s', new_fstab_line.strip(), ETC_FSTAB)
        return
    # needs to be added
    if not old_fstab_line:
        append_to_fstab(device, mount_location, file_system, options,
                        dump_freq, pass_num)
        return
    # just in case...
    # log fstab content before updating it
    log.debug(read_fstab())
    remove_from_fstab(device)
    append_to_fstab(device, mount_location, file_system, options, dump_freq,
                    pass_num)


def get_builders_from(jacuzzi_metadata_file):
    """Returns the builders list for the metadata file.
       If the input file cannot be decoded or it does not exist, returns []"""
    try:
        with open(jacuzzi_metadata_file) as data_file:
            json_data = json.load(data_file)
    except (IOError, ValueError, AttributeError):
        log.debug('%s does not exist or it cannot be decoded or is None',
                  jacuzzi_metadata_file)
        return []
    try:
        return json_data['builders']
    except (TypeError, KeyError):
        # json_data is not a dictionary or no keys
        return []


def mount_point():
    """Defines the mount point of the instance storage devices
       if a machine meets any of the following conditions:
       is part of a jacuzzi pool
       is a try slave,
       has enough disk space,
       the instance storage space is mounted under BUILDS_SLAVE_MNT.
       For any other machine the mount point is INSTANCE_STORAGE_MNT
    """
    # default mount point
    _mount_point = INSTANCE_STORAGE_MNT
    if len(get_builders_from(JACUZZI_METADATA_JSON)) in range(1, 4):
        # if there are 1, 2 or 3 builders: I am a Jacuzzi!
        log.info('jacuzzi:    yes')
        _mount_point = BUILDS_SLAVE_MNT
    else:
        log.info('jacuzzi:    no')
    try:
        with open('/etc/slave-trustlevel', 'r') as trustlevel_in:
            trustlevel = trustlevel_in.read().strip()
        log.info('trustlevel: %s', trustlevel)
        if trustlevel == 'try':
            _mount_point = BUILDS_SLAVE_MNT
    except IOError:
        # IOError   => file does not exist
        log.info('/etc/slave-trustlevel does not exist')
    # test if device has enough space, if so mount the disk
    # in BUILDS_SLAVE_MNT regardless the type of machine
    # assumption here: there's only one volume group
    device_size = vg_size()
    if device_size >= REQ_BUILDS_SIZE:
        log.info('disk size: %s GB >= REQ_BUILDS_SIZE (%d GB)',
                 device_size, REQ_BUILDS_SIZE)
        _mount_point = BUILDS_SLAVE_MNT
    else:
        log.info('disk size: %s GB < REQ_BUILDS_SIZE (%d GB)',
                 device_size, REQ_BUILDS_SIZE)
    log.info('mount point: %s', _mount_point)
    return _mount_point


def is_mounted(device):
    """Checks if a device is mounted"""
    if not device:
        log.debug('refusing to check if None device is mounted')
        return False
    mount_out = get_output_from_cmd('mount')
    log.debug("mount: %s", mount_out)
    for line in mount_out.splitlines():
        log.debug(line)
        if device in line:
            log.info('device: %s is mounted', device)
            return True
    log.info('device: %s is not mounted', device)
    return False


def umount(device):
    """Unmounts device"""
    if not device:
        log.debug('umount: device in None, returning')
        return
    get_output_from_cmd(['umount', device], raise_on_error=False)
    log.debug('%s is unmounted', device)
    # manage umount errors?


def disable_swap():
    """Disable swap file"""
    log.info('disabling swap files')
    run_cmd(['swapoff', '-a'])


def real_path(path):
    """Transforms a path to real absolute path following symlinks (if any)"""
    try:
        realpath = get_output_from_cmd(['readlink', '-f', path]).strip()
        log.debug('%s => %s', path, realpath)
        return realpath
    except CalledProcessError:
        # file does not exist
        return path


def is_dev_in_fstab(path):
    """Checks if a path is in fstab and returns the first element of the line
       (fs_spec). It returns None if path is not present in fstab
        e.g. /dev/mapper/vg-local and /dev/vg/local are both links to /dev/dm-0
        but only /dev/mapper is in fstab
    """
    # discard /
    fstab = [item.strip() for item in read_fstab()
             if not item.startswith('LABEL=root_dev')]
    # remove special mount points
    fstab = [item for item in fstab if 'none' not in item]
    for item in fstab:
        fstab_entry = item.partition(' ')[0]
        if fstab_entry:
            if real_path(fstab_entry) == real_path(path):
                log.debug('%s and %s point to the same device',
                          fstab_entry, path)
                return fstab_entry
    return None


def mount(device, _mount_point):
    """Mounts device according to fstab"""
    if not os.path.exists(_mount_point):
        log.debug('Creating directory %s', _mount_point)
        os.makedirs(_mount_point)
    log.info('mounting %s', device)
    run_cmd(['mount', device])


def mkdir_p(dst_dir, exist_ok=True):
    """same as os.makedirs(path, exist_ok=True) in python > 3.2"""
    try:
        os.makedirs(dst_dir)
        log.debug('created %s', dst_dir)
    except OSError, error:
        if error.errno == errno.EEXIST and os.path.isdir(dst_dir) and exist_ok:
            pass
        else:
            log.error('cannot create %s, %s', dst_dir, error)
            raise


def chown(path, user, group):
    user_group_str = '%s:%s' % (user, group)
    run_cmd(['chown', user_group_str, path])


def main():
    """Prepares the ephemeral devices"""
    logging.basicConfig(format="%(asctime)s - %(message)s", level=logging.INFO)
    devices = get_ephemeral_devices()
    if not devices:
        # no ephemeral devices, nothing to do, quit
        log.info('no ephemeral devices found')
        return
    if len(devices) > 1:
        # requires lvm
        log.info('found devices: %s', devices)
        device = lvmjoin(devices)
    else:
        # single device no need for lvm, just format
        device = devices[0]
        log.info('found device: %s', device)
        format_device(device)
    log.debug("Got %s", device)
    _mount_point = mount_point()
    ccache_dst = os.path.join(_mount_point, 'ccache')
    mock_dst = os.path.join(_mount_point, 'mock_mozilla')
    update_fstab(device, _mount_point, file_system='ext4',
                 options='defaults,noatime', dump_freq=0, pass_num=0)

    # prepare bind shares
    remove_from_fstab(CCACHE_DIR)
    update_fstab(ccache_dst, CCACHE_DIR, file_system='none',
                 options='bind,noatime', dump_freq=0, pass_num=0)
    remove_from_fstab(MOCK_DIR)
    update_fstab(mock_dst, MOCK_DIR, file_system='none',
                 options='bind,noatime', dump_freq=0, pass_num=0)
    # fstab might have been updated, umount the device and re-mount it
    if not is_mounted(device):
        # mount the main share so we can create the ccache dir
        mount(device, _mount_point)

    try:
        mkdir_p(ccache_dst)
        mkdir_p(mock_dst)
        # avoid multiple mounts of the same share/directory/...
        if not is_mounted(ccache_dst):
            mount(ccache_dst, CCACHE_DIR)
        if not is_mounted(mock_dst):
            mount(mock_dst, MOCK_DIR)
        # Make sure that the mount point are writable by cltbld
        for directory in (_mount_point, CCACHE_DIR):
            chown(directory, user='cltbld', group='cltbld')
        # mock_mozilla needs different permissions
        chown(MOCK_DIR, user='root', group='mock_mozilla')
        run_cmd(["chmod", "2775", MOCK_DIR])
    except OSError, error:
        # mkdir failed, CCACHE_DIR not mounted
        log.error(error)
        log.error('%s and/or %s not mounted', ccache_dst, mock_dst)


if __name__ == '__main__':
    main()
