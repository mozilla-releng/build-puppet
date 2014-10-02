# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::mozilla::osslsigncode {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemrelease {
                6.2: {
                    realize(Packages::Yumrepo['osslsigncode'])
                    package {
                        "osslsigncode":
                            ensure => "1.7.1-1.el6";
                    }
                }
                default: {
                    warning("Unrecognized CentOS version $::operatingsystemrelease")
                    package {
                        "osslsigncode":
                            ensure => present;
                    }
                }
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
