# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::bridge_utils {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        'bridge-utils':
                            ensure => '1.5-2ubuntu6';
                    }
                }
                16.04: {
                    package {
                        'bridge-utils':
                            ensure => '1.5-9ubuntu1';
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
