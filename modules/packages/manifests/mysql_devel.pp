# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mysql_devel {
    case $operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['mysql'])
            package {
                'mysql-devel':
                    ensure => '5.1.73-8.el6_8';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
