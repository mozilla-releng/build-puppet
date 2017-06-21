# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::mock_mozilla {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['mock_mozilla'])
            package {
                'mock_mozilla':
                    ensure => '1.0.3-1.el6';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
