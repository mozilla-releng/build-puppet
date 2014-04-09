# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::openssl {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemrelease {
                6.2: {
                    package {
                        "openssl":
                            ensure => "1.0.0-20.el6";
                    }
                }
                6.5: {
                    package {
                        "openssl":
                            ensure => "1.0.1e-16.el6_5.7";
                    }
                }
                default: {
                    warning("Unrecognized CentOS version $::operatingsystemrelease")
                    package {
                        "openssl":
                            ensure => present;
                    }
                }
            }
        }

        Darwin: {
            # already installed (maybe as part of xcode?)
        }

        Ubuntu: {
            package {
                "openssl":
                    ensure => latest;  # TODO: pin version (bug 994061)
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
