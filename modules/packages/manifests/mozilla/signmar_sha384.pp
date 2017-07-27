# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::signmar_sha384 {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['signmar'])
            package {
                'signmar-sha384':
                    ensure => '56.0a1-1.el6';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
