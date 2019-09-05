# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::google_chrome {
    anchor {
        'packages::mozilla::google_chrome::begin': ;
        'packages::mozilla::google_chrome::end': ;
    }

    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                realize(Packages::Aptrepo['google_chrome'])
                16.04: {
                    Anchor['packages::mozilla::google_chrome::begin'] ->
                    package {
                        'google-chrome-stable':
                            ensure => '76.0.3809.132-1';
                    } -> Anchor['packages::mozilla::google_chrome::end']
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
