# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::net_snmp_utils {
    case $::operatingsystem {
        CentOS: {
            package {
                'net-snmp-utils':
                    ensure => '5.5-49.el6';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
