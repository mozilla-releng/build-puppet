# == Class: vmwaretools
#
# This class handles installing the VMware Tools via the archives distributed
# by VMware. Upgrades and downgrades are also supported.
#
# The archive can either be placed on an HTTP-accessible location, or within
# this module's 'files' directory.
#
# === Parameters:
#
# [*version*]
#   The numeric version of the tools that you want to install. This can be
#   found by looking at the filename of the archive - e.g. 8.6.5-621624
#
# [*working_dir*]
#   The directory to store files in.
#   Default: '/tmp/vmwaretools' (string)
#
# [*redhat_install_devel*]
#   If you really want to install kernel headers on RedHat-derivative operating
#   systems - you will likely not need this as most RH distros have
#   pre-compiled kernel modules.
#   Default: false (boolean)
#
# [*archive_url*]
#   Specify an HTTP location to download the archive from - this is useful when
#   you want to avoid packaging the installer with your Puppet code.  NOTE that
#   this does NOT include the filename, just the path to the file. The filename
#   will be constucted as 'VMwareTools-$version.tar.gz'.
#   Default: 'puppet' (string)
#
# [*archive_md5*]
#   md5sum of the archive - required if using an HTTP location above.
#   Default: '' (empty string)
#
# [*fail_on_non_vmware*]
#   Output a hard failure message if the module is run on non-vmware hardware.
#   Default: false (boolean)
#
# [*keep_working_dir*]
#   Keep the working dir on disk after installation.
#   Default: false (boolean)
#
# [*prevent_downgrade*]
#   If the system has a version of the tools installed which is newer that what
#   is set in the version parameter, do not downgrade the tools.
#   Default: true (boolean)
#
# == Actions:
#
# * Compares installed version with the configured version
# * Transfer the VMware Tools archive to the target agent (via Puppet or HTTP)
# * Untar the archive and run vmware-install-tools.pl
# * Removes open-vm-tools
#
# === Requires:
#
# * HTTP download script: wget, awk, md5sum
#
# === Sample Usage:
#
# To accept defaults:
#
#   include vmwaretools
#
# To specify a non-default version, working directory and HTTP URL:
#
#   class { 'vmwaretools':
#     version     => '8.6.5-621624',
#     working_dir => '/tmp/vmwaretools'
#     archive_url => 'http://server.local/my/dir',
#     archive_md5 => '9df56c317ecf466f954d91f6c5ce8a6f',
#   }
#
# === Authors:
#
# Craig Watson <craig@cwatson.org>
#
# === Copyright:
#
# Copyright (C) 2013 Craig Watson
# Published under the GNU General Public License v3
#
class vmwaretools (
  $version              = '9.0.0-782409',
  $working_dir          = '/tmp/vmwaretools',
  $redhat_install_devel = false,
  $archive_url          = 'puppet',
  $archive_md5          = '',
  $fail_on_non_vmware   = false,
  $keep_working_dir     = false,
  $prevent_downgrade    = true,
) {

  if $archive_url != 'puppet' and $archive_md5 == '' {
    fail 'MD5 not given for VMware Tools installer package'
  }

  if $::virtual != 'vmware' and $fail_on_non_vmware == true {
    fail 'Not a VMware platform.'
  }

  include vmwaretools::params
  include vmwaretools::kernel_upgrade
  include vmwaretools::install
  include vmwaretools::config

}
