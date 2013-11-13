# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::android_sdk18 {
    case $::operatingsystem {
        Ubuntu: {
            package {
                # Built from https://github.com/rail/android-sdk
                'android-sdk18':
                    ensure => '0.r18moz1-0moz1';
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
