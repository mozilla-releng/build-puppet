# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::docker_ce {

    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04: {
                    realize(Packages::Aptrepo['docker_ce'])
                    package {
                        'docker-ce':
                            ensure => latest;
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
