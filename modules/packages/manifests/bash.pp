# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::bash {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemmajrelease {
                6: {
                    realize(Packages::Yumrepo['bash'])
                    package {
                        "bash":
                            ensure => "4.1.2-15.el6_5.2";
                    }
                }
                default: {
                    fail("Unrecognized CentOS version $::operatingsystemrelease")
                }
            }
        }
        Darwin: {
            packages::pkgdmg {
                bash:
                    version => "3.2-moz2";
            }
        }

        Ubuntu: {
            realize(Packages::Aptrepo['bash'])
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        "bash":
                            ensure => '4.2-2ubuntu2.3';
                    }
                }
                14.04: {
                    package {
                        "bash":
                            ensure => '4.3-7ubuntu1.3';
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version $::operatingsystemrelease")
                }
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
