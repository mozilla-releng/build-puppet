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
                    ensure => absent;
            }
            exec {
                "update-mta-alternatives":
                    command     => "/usr/sbin/alternatives --auto mta",
                    refreshonly => true;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
