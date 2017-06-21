# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mailx {
    case $::operatingsystem {
        Ubuntu: {
            package {
                'heirloom-mailx':
                    ensure => latest;
            }
        }

        CentOS: {
            realize(Packages::Yumrepo['mailx'])
            package {
                'mailx':
                    ensure => '12.4-8.el6_6';
            }
        }

        Darwin: {
            # mail(1) ships with OS X 'cuz it's BSD
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
