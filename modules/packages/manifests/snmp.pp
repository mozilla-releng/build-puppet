# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::snmp {
    case $::operatingsystem {
        CentOS: {
            package {
                [ "net-snmp",
                  "net-snmp-utils",
                ]:
                    ensure => '5.5-49.el6_5.1';
            }
        }
        Ubuntu: {
            package {
                "snmp":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
