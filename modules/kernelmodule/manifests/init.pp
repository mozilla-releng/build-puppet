# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This module installs and enables Linux kernel modules
define kernelmodule($module=$title, $module_args='', $packages=null) {
    case $::operatingsystem {
        Ubuntu: {
            exec {
                "modprobe-$module":
                    command     => "modprobe $module $module_args",
                    unless      => "lsmod | grep -qw ^${module}",
                    refreshonly => true,
                    path        => "/sbin:/bin:/usr/bin";
                "add-$module-to-etc-modules":
                    command => "echo ${module} >> /etc/modules",
                    unless  => "grep -qw ^${module} /etc/modules",
                    path    => "/sbin:/bin:/usr/bin";
            }
            if ($packages != null) {
                package {
                    $packages:
                        ensure => latest,
                        notify => Exec["modprobe-$module"];
                }
            }
        }
        default: {
            fail("$::operatingsystem is not supported")
        }
    }
}
