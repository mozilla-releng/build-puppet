# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::nss_tools {
    case $::operatingsystem {
        CentOS: {
            package {
                "nss-tools":
                    ensure => '3.15.3-6.el6_5';
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
