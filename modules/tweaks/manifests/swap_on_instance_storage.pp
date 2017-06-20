# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class tweaks::swap_on_instance_storage {
    case $::operatingsystem {
        CentOS: {
            file {
                '/etc/init.d/add_swap':
                    source => 'puppet:///modules/tweaks/add_swap',
                    mode   => '0755';
            }
            service {
                'add_swap':
                    ensure  => running,
                    enable  => true,
                    require => File['/etc/init.d/add_swap'];
            }
        }
    }
}
