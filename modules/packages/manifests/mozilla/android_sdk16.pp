# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::android_sdk16 {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['android-sdk'])
            package {
                # See https://wiki.mozilla.org/ReleaseEngineering/How_To/Build_An_Android_SDK_rpm
                'android-sdk16':
                    ensure => 'r16-0moz2';
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
