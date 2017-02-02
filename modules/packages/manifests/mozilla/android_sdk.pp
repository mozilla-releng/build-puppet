class packages::mozilla::android_sdk {
  $basedir = '/tools/android-sdk'
  $build_tools_version = '23.0.3'

  $zip_file_name = "android-sdk-linux_build-tools-$build_tools_version.tar.xz"
  $zip_location = "$basedir/$zip_file_name"
  # /!\ Value redefined used in signing_scriptworker::init
  $zipalign_location = "$basedir/build-tools/$build_tools_version/zipalign"

  case $::operatingsystem {
    CentOS: {
      file {
        $basedir:
          ensure => directory;

        $zip_location:
          ensure  => file,
          source  => "puppet:///repos$p/ZIPs/$zip_file_name";
      }

      package {
          [ 'glibc.i686', 'zlib.i686', 'libstdc++.i686' ]:
              ensure => latest;
      }

      exec {
        "/bin/tar xvf $zip_location --strip-components=1":  # strip-components removes the first directory called "android-sdk-linux"
          creates => $zipalign_location,
          cwd => $basedir,
          require => File[$zip_location];
      }
    }
    default: {
      fail("cannot install on $::operatingsystem")
    }
  }
}
