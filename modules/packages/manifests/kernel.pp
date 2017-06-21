# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::kernel {
    include stdlib
    include config
    include needs_reboot

    $current_kernel = $config::current_kernel
    $obsolete_kernel_list = $config::obsolete_kernels

    # At a minimum the current kernel must be specified otherwise this module is ignored
    if $current_kernel {
        case $::operatingsystem {
            'CentOS': {
                realize(Packages::Yumrepo['kernel'])
                $kernel_ver = "${current_kernel}.${::architecture}"
                # No need to munipulate version string
                $strip_ver  = $current_kernel
                # see https://bugzilla.mozilla.org/show_bug.cgi?id=1113328#c14
                package { 'bfa-firmware':
                    ensure => absent,
                }
                package {
                    [ "kernel-${current_kernel}",
                      "kernel-headers-${current_kernel}",
                      "kernel-firmware-${current_kernel}"]:
                          ensure  => present,
                          require => Package['bfa-firmware'],
                }
                grub::defaults {'grub-defaults':
                    kern => $kernel_ver;
                }
                # uninstall obsolete kernels only if the current specified kernel is running
                if $::kernelrelease == $kernel_ver and ! empty($obsolete_kernel_list) {
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
                if $::lsbdistrelease == '12.04' and $::architecture == 'i386' {
                    $suffix = '-generic-pae' }
                else {
                    $suffix = '-generic' }
                # Because ubuntu is "special", the kernel version string must be altered
                $strip_ver = regsubst($current_kernel, '^(\d+)\.(\d+)\.(\d+)\.(\d+).(\d+)', '\1.\2.\3-\4')
                $kernel_ver = "${strip_ver}${suffix}"
                package {
                    [ "linux-image${suffix}", "linux-headers${suffix}" ]:
                          ensure => $current_kernel
                } ->
                package {
                    "linux${suffix}" :
                          ensure => $current_kernel
                }
                grub::defaults {'grub-defaults':
                    kern => $kernel_ver;
                }
                # uninstall obsolete kernels only if the current specified kernel is running including both generic and generic-pae
                if $::kernelrelease == $kernel_ver and ! empty($obsolete_kernel_list) {
                    $obsolete_kernels  = suffix( prefix( $obsolete_kernel_list, 'linux-image-' ), '-generic')
                    $obsolete_headers  = suffix( prefix( $obsolete_kernel_list, 'linux-headers-' ), '-generic' )
                    $obsolete_kernels_pae  = suffix( prefix( $obsolete_kernel_list, 'linux-image-' ), '-generic-pae')
                    $obsolete_headers_pae  = suffix( prefix( $obsolete_kernel_list, 'linux-headers-' ), '-generic-pae' )
                    $obsolete_headers_all  = prefix( $obsolete_kernel_list, 'linux-headers-' )
                    package { [ $obsolete_kernels, $obsolete_headers, $obsolete_headers_all, $obsolete_kernels_pae, $obsolete_headers_pae ]:
                        ensure => absent
                    }
                }
            }
            default: {
                fail( "${::operatingsystem} is not supported by the kernel upgrades" )
            }
        }

        # Make sure current kernel isn't also listed as obsolete
        if $strip_ver in $obsolete_kernel_list {
            fail ( "Kernel defined as current (${current_kernel}) is also defined in obsolete kernel list" )
        }

        # This file is read by needs_reboot_kernel_upgrade.rb to determine if
        # a reboot is needed after a new kernel package is installed
        file { '/.kernel_release':
            ensure  => file,
            content => $kernel_ver,
            notify  => Exec['reboot_semaphore'];
        }
    }
}
