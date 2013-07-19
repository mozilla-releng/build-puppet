# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::postfix {
    case $::operatingsystem {
        CentOS: {
            package {
                "postfix":
                    ensure => latest;
                "ssmtp":
                    notify => Exec["update-mta-alternatives"],
                    ensure => absent,
                    before => Package["postfix"];
            }
            exec {
                "update-mta-alternatives":
                    command     => "/usr/sbin/alternatives --auto mta",
                    refreshonly => true;
            }
        }

        Darwin: {
            # Postfix ships with OS X
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
