# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::cpu_checker {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        'cpu-checker':
                            ensure => '0.7-0ubuntu1';
                    }
                }
                16.04: {
                    package {
                        'cpu-checker':
                            ensure => '0.7-0ubuntu7';
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }
        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
