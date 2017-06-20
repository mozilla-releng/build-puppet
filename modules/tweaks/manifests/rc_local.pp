# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class tweaks::rc_local {

    case $::operatingsystem {
        CentOS, Ubuntu: {
            file {
                '/etc/rc.local':
                    source => 'puppet:///modules/tweaks/rc.local',
                    mode   => '0755';
                '/etc/init.d/rc.local':
                    source  => 'puppet:///modules/tweaks/rc.local.init.d',
                    require => File['/etc/rc.local'],
                    mode    => '0755';
            }
            service {
                'rc.local':
                    enable  => true,
                    require => File['/etc/init.d/rc.local'];
            }
        }
    }
}
