# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xe_guest_utilities {

    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04: {
                    package {
                        'xe-guest-utilities':
                            ensure => '6.2.0-1120+dsf1-0ubuntu3'
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        default: {
            fail('Cannot install xe-guest-utilities on this platform')
        }
    }
}
