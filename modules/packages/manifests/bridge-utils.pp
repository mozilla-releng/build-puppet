# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::bridge-utils {
    case $::operatingsystem {
        Ubuntu: {
            package {
                "bridge-utils":
                    ensure => "1.5-2ubuntu6";
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
