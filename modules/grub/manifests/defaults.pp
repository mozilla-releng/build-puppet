# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define grub::defaults($kern=0) {
    include grub

    case $operatingsystem {
        'Ubuntu': {
            file {
                '/etc/default/grub':
                    ensure  => present,
                    content => template("grub/defaults.erb");
            } ~>
            exec { 'update-grub':
                command => '/usr/sbin/update-grub',
                subscribe   => File['/etc/default/grub'],
                refreshonly => true,
                require => Class [ 'grub' ];
            }
        }
        'CentOS': {
            file { '/boot/grub/grub.conf':
                mode  => 600,
                audit => content,
            } ~>
            exec { 'grubby':
                command => "/sbin/grubby --set-default=/boot/vmlinuz-${kern}",
                refreshonly => true,
            }
        }
    }
}
