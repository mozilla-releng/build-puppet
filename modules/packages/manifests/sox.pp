# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::sox {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        ['libsox-fmt-alsa', 'libsox-fmt-base', 'libsox1b', 'sox']:
                            ensure => latest;
                    }
                }
                16.04: {
                    package {
                        ['libsox-fmt-alsa', 'libsox-fmt-base', 'libsox2', 'sox']:
                            ensure => '14.4.1-5';
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }

            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
