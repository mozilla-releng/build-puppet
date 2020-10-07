# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::ffmpeg {

    anchor {
        'packages::mozilla::ffmpeg::begin': ;
        'packages::mozilla::ffmpeg::end': ;
    }

    case $::operatingsystem {
        Ubuntu: {
            realize(Packages::Aptrepo['ffmpeg'])
            case $::operatingsystemrelease {
                16.04: {
                    Anchor['packages::mozilla::ffmpeg::begin'] ->
                    package {
                        'ffmpeg':
                            ensure => latest;
                    } -> Anchor['packages::mozilla::ffmpeg::end']
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
