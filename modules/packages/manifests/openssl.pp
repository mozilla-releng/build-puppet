# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::openssl {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemrelease {
                6.2: {
                    package {
                        ["openssl", "openssl-devel"]:
                            ensure => "1.0.0-20.el6";
                    }
                }
                6.5: {
                    realize(Packages::Yumrepo['openssl'])
                    package {
                        ["openssl", "openssl-devel"]:
                            ensure => "1.0.1e-16.el6_5.15";
                    }
                }
                default: {
                    warning("Unrecognized CentOS version $::operatingsystemrelease")
                    package {
                        ["openssl", "openssl-devel"]:
                            ensure => present;
                    }
                }
            }
        }

        Darwin: {
            # already installed (maybe as part of xcode?)
        }

        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        ["openssl", "libssl1.0.0", "libssl-dev"]:
                            ensure => '1.0.1-4ubuntu5.12';
                    }
                }
                14.04: {
                    package {
                        ["openssl", "libssl1.0.0", "libssl-dev"]:
                            ensure => '1.0.1f-1ubuntu2.1';
                    }
                }
                default: {
                    warning("Unrecognized Ubuntu version $::operatingsystemrelease")
                    package {
                        ["openssl", "libssl1.0.0", "libssl-dev"]:
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
