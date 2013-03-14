# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# This module installs and enables Linux kernel modules
define kernelmodule($module=$title, $module_args='', $packages=null) {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            exec {
                "modprobe-$module":
                    command => "modprobe $module $module_args",
                    unless  => "lsmod | grep -qw ^${module}",
                    path    => "/sbin:/bin:/usr/bin";
            }
            if ($packages != null) {
                package {
                    $packages:
                        ensure => latest,
                        before => Exec["modprobe-$module"];
                }
            }
        }
        default: {
            fail("$::operatingsystem is not supported")
        }
    }
}
