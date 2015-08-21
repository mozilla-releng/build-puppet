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
                            # this is the latest version from our mirror of 'updates'
                            ensure => "1.0.0-20.el6_2.2";
                    }
                }
                6.5: {
                    realize(Packages::Yumrepo['openssl'])
                    package {
                        ["openssl", "openssl-devel"]:
                            ensure => "1.0.1e-30.el6_5.2";
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
            realize(Packages::Aptrepo['openssl'])
            case $::operatingsystemrelease {
                12.04: {
                    package {
                        ["openssl", "libssl1.0.0", "libssl-dev"]:
                            ensure => '1.0.1-4ubuntu5.20';
                    }
                }
                14.04: {
                    package {
                        ["openssl", "libssl1.0.0", "libssl-dev"]:
                            ensure => '1.0.1f-1ubuntu2.7';
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

        Windows: {
            packages::pkgzip {
                "openssl-09.8h-1-win32-exe.zip":
                    zip => "openssl-09.8h-1-win32-exe.zip",
                    target_dir => '"C:\Program Files (x86)"';
                "openssl-09.8h-1-win32-dll.zip":
                    zip => "openssl-09.8h-1-win32-dll.zip",
                    target_dir => '"C:\Windows\System32"';
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
