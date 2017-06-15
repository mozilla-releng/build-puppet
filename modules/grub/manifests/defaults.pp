# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define grub::defaults($kern=0) {
    include grub
    include needs_reboot

    case $::operatingsystem {
        'Ubuntu': {
            if $::ec2_instance_id != '' {
                # Provide menu.lst for ec2 instances which use legacy grub
                file {
                    '/boot/grub/menu.lst':
                        ensure  => present,
                        content => template('grub/ubuntu-menu.lst.erb'),
                        notify  => Exec['reboot_semaphore'];
                }
            }
            else {
                # Use update-grub when dealing with grub2 (non-legacy)
                file {
                    '/etc/default/grub':
                        ensure  => present,
                        content => template('grub/defaults.erb'),
                        notify  => Exec['reboot_semaphore'];
                } ~>
                exec { 'update-grub':
                    command     => '/usr/sbin/update-grub',
                    subscribe   => File['/etc/default/grub'],
                    refreshonly => true,
                    require     => Class [ 'grub' ];
                }
            }
        }
        'CentOS': {
            file { '/boot/grub/grub.conf':
                mode   => '0600',
                audit  => content,
                notify => Exec['reboot_semaphore'];
            } ~>
            exec { 'grubby':
                command     => "/sbin/grubby --set-default=/boot/vmlinuz-${kern}",
                refreshonly => true,
            }
        }
    }
}
