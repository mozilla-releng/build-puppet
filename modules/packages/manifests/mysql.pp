# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mysql {
    case $::operatingsystem {
        CentOS: {
            package {
                'mysql':
                    ensure => '5.1.73-3.el6_5';
            }
        }
        Ubuntu: {
            package {
                'mysql-client':
                    ensure => latest;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
