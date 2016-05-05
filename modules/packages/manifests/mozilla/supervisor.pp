# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::supervisor {
    case $::operatingsystem {
        CentOS: {
            # this repo contains a custom-built supervisor along with
            # its dependencies from EPEL
            realize(Packages::Yumrepo['supervisor'])
            package {
                'supervisor':
                    ensure => '3.0-0.10.b2.el6';
            }
            file {
                '/etc/logrotate.d/supervisor':
                    require => Package['supervisor'],
                    source  => 'puppet:///modules/packages/supervisor.logrotate';
            }
        }

        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
