# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::bash {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemrelease {
                6.5: {
                    realize(Packages::Yumrepo['bash'])
                    package {
                        "bash":
                            ensure => "4.1.2-15.el6_5.1";
                    }
                }
                default: {
                    fail("Unrecognized CentOS version $::operatingsystemrelease")
                }
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
