# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nodejs {
    case $::operatingsystem {
        Ubuntu: {
            package {
                # Install nodejs-legacy package which contains node -> nodejs symlink
                ["nodejs", "nodejs-legacy"]:
                    ensure => '0.8.18~dfsg1-1mozilla1';
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
