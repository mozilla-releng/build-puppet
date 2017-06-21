# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::procmail {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['procmail'])
            package {
                'procmail':
                    ensure => '3.22-25.1.el6_5.1';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
