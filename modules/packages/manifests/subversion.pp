# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::subversion {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['subversion'])
            package {
                'subversion':
                    ensure => '1.6.11-15.el6_7';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
