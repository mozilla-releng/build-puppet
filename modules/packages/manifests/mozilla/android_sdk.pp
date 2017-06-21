# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define packages::mozilla::android_sdk(
    $username,
    $group,

    $basedir             = '/tools/android-sdk',
    $build_tools_version = $title,
    $zipalign_location   = "${basedir}/build-tools/${build_tools_version}/zipalign",

) {
  $archive_file_name = "android-sdk-linux_build-tools-${build_tools_version}.tar.xz"
  $archive_location = "${basedir}/${archive_file_name}"

  File {
    mode      => '0640',
    owner     => $username,
    group     => $group,
    show_diff => false,
  }

  file {
    $basedir:
      ensure => directory;

    $archive_location:
      ensure => file,
      source => "puppet:///repos/ZIPs/${archive_file_name}";
  }

  exec {
    "/bin/tar xvf ${archive_location} --strip-components=1":  # strip-components removes the first directory called "android-sdk-linux"
      creates => $zipalign_location,
      cwd     => $basedir,
      group   => $group,
      require => File[$archive_location],
      user    => $username;
  }

  case $::operatingsystem {
    CentOS: {
      package {
          [ 'glibc.i686', 'zlib.i686', 'libstdc++.i686' ]:
              ensure => latest;
      }
    }
    default: {
      fail("Cannot install on ${::operatingsystem}")
    }
  }
}
