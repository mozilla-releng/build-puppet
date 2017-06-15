# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This module installs and enables Linux kernel modules
define kernelmodule($module=$title, $module_args='', $packages=null) {
    case $::operatingsystem {
        Ubuntu,CentOS: {
            exec {
                "modprobe-${module}":
                    command     => "modprobe ${module} ${module_args}",
                    unless      => "lsmod | grep -qw ^${module}",
                    refreshonly => true,
                    path        => '/sbin:/bin:/usr/bin';
            }
            case $::operatingsystem {
                Ubuntu: {
                    exec {
                        "add-${module}-to-etc-modules":
                            command => "echo ${module} >> /etc/modules",
                            unless  => "grep -qw ^${module} /etc/modules",
                            path    => '/sbin:/bin:/usr/bin',
                            notify  => Exec["modprobe-${module}"];
                    }
                }
                CentOS: {
                    include kernelmodule::rc_modules
                    exec {
                        "add-${module}-to-etc-rc-modules":
                            command => "echo modprobe ${module} >> /etc/rc.modules",
                            unless  => "grep -qw '^modprobe ${module}' /etc/rc.modules",
                            path    => '/sbin:/bin:/usr/bin',
                            require => Class['kernelmodule::rc_modules'],
                            notify  => Exec["modprobe-${module}"];
                    }
                }
            }

            if ($packages != null) {
                package {
                    $packages:
                        ensure => latest,
                        notify => Exec["modprobe-${module}"];
                }
            }
        }
        default: {
            fail("${::operatingsystem} is not supported")
        }
    }
}
