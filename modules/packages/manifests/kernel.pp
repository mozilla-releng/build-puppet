# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::kernel {
    include stdlib
    include config

    $current_kernel = $config::current_kernel
    $obsolete_kernel_list = $config::obsolete_kernels

    # At a minimum the current kernel must be specified otherwise this module is ignored
    if $current_kernel {
        if $current_kernel in $obsolete_kernel_list {
            fail ( "Kernel defined as current (${current_kernel}) is also defined in obsolete kernel list" )
        }
        case $operatingsystem {
            'CentOS': {
                realize(Packages::Yumrepo['kernel'])
                $kernel_ver = "${current_kernel}.${architecture}"
                package {
                    [ "kernel-${current_kernel}",
                      "kernel-headers-${current_kernel}",
                      "kernel-firmware-${current_kernel}"]:
                          ensure => present
                }
                # uninstall obsolete kernels only if the current specified kernel is running
                if $kernelrelease == $kernel_ver and ! empty($obsolete_kernel_list) {
                    $obsolete_kernels  = prefix( $obsolete_kernel_list, 'kernel-' )
                    $obsolete_headers  = prefix( $obsolete_kernel_list, 'kernel-headers-' )
                    $obsolete_firmware = prefix( $obsolete_kernel_list, 'kernel-firmware-' )
                    package { [ $obsolete_kernels, $obsolete_headers, $obsolete_firmware ]:
                        ensure => absent
                    }
                }
            }
            'Ubuntu': {
                realize(Packages::Aptrepo['kernel'])
                # there is no pae version for trusry; only --generic
                if $lsbdistrelease == '12.04' and $architecture == 'i386' {
                    $suffix = '-generic-pae' }
                else {
                    $suffix = '-generic' }

                $kernel_ver = "${current_kernel}${suffix}"
                package {
                    [ "linux-image-${current_kernel}${suffix}",
                      "linux-headers-${current_kernel}${suffix}" ]:
                          ensure => present
                }
                # uninstall obsolete kernels only if the current specified kernel is running
                if $kernelrelease == $kernel_ver and ! empty($obsolete_kernel_list) {
                    $obsolete_kernels  = suffix( prefix( $obsolete_kernel_list, 'linux-image-' ), $suffix )
                    $obsolete_headers  = suffix( prefix( $obsolete_kernel_list, 'linux-headers-' ), $suffix )
                    $obsolete_headers_all  = prefix( $obsolete_kernel_list, 'linux-headers-' )
                    package { [ $obsolete_kernels, $obsolete_headers, $obsolete_headers_all ]:
                        ensure => absent
                    }
                }
            }
            default: {
                fail( "${operatingsystem} is not supported by the kernel upgrades" )
            }
        }
        # This file is read by needs_reboot_kernel_upgrade.rb to determine if
        # a reboot is needed after a new kernel package is installed
        file { '/.kernel_release':
            content => "${kernel_ver}",
            ensure  => present;
        }
    }
}
