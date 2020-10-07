# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::imagemagick {

    anchor {
        'packages::mozilla::imagemagick::begin': ;
        'packages::mozilla::imagemagick::end': ;
    }

    case $::operatingsystem {
        Ubuntu: {
            realize(Packages::Aptrepo['imagemagick'])
            case $::operatingsystemrelease {
                16.04: {
                    Anchor['packages::mozilla::imagemagick::begin'] ->
                    package {
                        'imagemagick':
                            ensure => latest;
                    } -> Anchor['packages::mozilla::imagemagick::end']
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
