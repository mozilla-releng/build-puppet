# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::screen {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            package {
                'screen':
                    ensure => latest;
            }
        }
        Darwin : {
            # installed by default
        }
        Windows: {
            fail('Screen is not supportable on Windows')
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
