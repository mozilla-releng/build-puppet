# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::rsyslog {
    case $::operatingsystem {
        CentOS: {
            package {
                "rsyslog":
                    ensure => "5.8.10-8.el6";
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
