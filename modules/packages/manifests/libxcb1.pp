# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::libxcb1 {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    realize(Packages::Aptrepo['libxcb'])
                    package {
                        'libxcb1':
                            ensure => '1.8.1-2ubuntu2.1mozilla2';
                    }
                }
                16.04: {
                    package {
                        'libxcb1':
                            ensure => '1.11.1-1ubuntu1';
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
