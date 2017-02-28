# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::libxcb1 {
    case $::operatingsystem {
        Ubuntu: {
            realize(Packages::Aptrepo['libxcb'])
            package {
                "libxcb1":
                    ensure => "1.8.1-2ubuntu2.1mozilla2";
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
