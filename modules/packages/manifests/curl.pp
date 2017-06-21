# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::curl {
    case $::operatingsystem {
        CentOS: {
            package {
                'curl':
                    ensure => '7.19.7-37.el6_4';
            }
        }
        Ubuntu: {
            package {
                'curl':
                    ensure => '7.47.0-1ubuntu2.2';
            }
        }
        Darwin: {
            # curl is installed with base install image
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
