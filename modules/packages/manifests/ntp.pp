# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::ntp {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['ntp'])
            package {
                ['ntp', 'ntpdate']: # ntp depends on ntpdate
                    ensure => '4.2.6p5-10.el6.centos.1';
            }
        }
        Ubuntu: {
            package {
                'ntp':
                    ensure => latest;
            }
        }
        Darwin: {
            #ntpd is installed with base install image
        }
        Windows: {
            # Windows includes the Windows Time Service
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
