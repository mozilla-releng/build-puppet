# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nslookup {
    case $::operatingsystem {
        CentOS: {
            package {
                "bind-utils":  #Provided by bind-utils
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
