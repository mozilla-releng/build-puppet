# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# note that this differs from packages::mozilla::py27_virtualenv in that it
# just uses the system virtualenv
class packages::virtualenv {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04: {
                    package {
                        'python-virtualenv':
                            ensure => '15.0.1+ds-3ubuntu1';
                    }
                }
                default: {
                    fail("Cannot install on ${::operatingsystem} ${::operatingsystemrelease}")
                }
            }
        }
        Darwin: {
            # On Darwin we use the puppetagain Python exclusively, so defer
            # to its associated virtualenv
            class {'packages::mozilla::py27_virtualenv': }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

