# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class talos {

    include httpd
    include dirs::builds::slave
    include users::builder
    include talos::settings
    if ($::operatingsystem != 'Windows') {
        include packages::xvfb
        include packages::nodejs
    }

    # Due to different tests and flavors of tests run on different platforms,
    # each has a peculiar set of packages required, with little or no overlap.
    # This is the place to add such peculiarities, preferably commented with
    # the relevant bug.
    case $::operatingsystem {
        Ubuntu: {
            # Ubuntu specific packages
            include packages::llvm
            include packages::sox
            include packages::libxcb1
            # required for the 32-bit reftests per :ahal, bug 837268
            include packages::ia32libs
            include packages::gstreamer
            include tweaks::cron
            include tweaks::resolvconf
            # see bug 914627
            include packages::system_git

            kernelmodule {
                'snd_aloop':
                    packages => ['libasound2'];
                'v4l2loopback':
                    packages => ['v4l2loopback-dkms'];
            }

            case $::hardwaremodel {
                # We only run Android x86 emulator kvm jobs on
                # 64-bit host machines
                'x86_64': {
                    include packages::cpu_checker
                    include packages::qemu_kvm
                    include packages::bridge_utils
                }
            }
        }
        Darwin: {
            # Darwin-specific packages
            case $::macosx_productversion_major {
                10.7: {
                    include packages::javadeveloper_for_os_x
                }
                10.8, 10.10 : {
                    include packages::javadeveloper_for_os_x
                    # gcc is needed from this package to compile psutil
                    include packages::xcode
                }
            }
        }
    }

    case $::operatingsystem {
        Darwin, CentOS, Ubuntu: {
            file {
                [ '/builds/slave/talos-data',
                  $talos::settings::apachedocumentroot]:
                    ensure => directory,
                    owner  => $users::builder::username,
                    group  => $users::builder::group,
                    mode   => '0755';
            }
            file {
                '/builds/talos-slave':
                    ensure => absent,
                    force  => true;
            }
            httpd::config {
                'talos.conf':
                    content => template('talos/talos-httpd.conf.erb');
            }
        }
        Windows: {

        include dirs::slave::talos_data::talos
        include packages::httpd

            file {
                'C:/Program Files/Apache Software Foundation/Apache2.2/conf/httpd.conf':
                    content => template('talos/talos-httpd.conf.erb'),
                    require => Packages::Pkgmsi['Apache HTTP Server 2.2.22'],
                    notify  => Service['Apache2.2'];
            }
        }
    }
}
