# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::openssl {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemrelease {
                6.2: {
                    package {
                        ['openssl', 'openssl-devel']:
                            # this is the latest version from our mirror of 'updates'
                            ensure => '1.0.0-20.el6_2.2';
                    }
                }
                6.5: {
                    realize(Packages::Yumrepo['openssl'])
                    package {
                        ['openssl', 'openssl-devel']:
                            ensure => '1.0.1e-48.el6_8.4';
                    }
                }
                default: {
                    fail("CentOS ${::operatingsystemrelease} is not supported")
                }
            }
        }

        Darwin: {
            # already installed (maybe as part of xcode?)
        }

        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    realize(Packages::Aptrepo['openssl'])
                    package {
                        ['openssl', 'libssl1.0.0', 'libssl-dev']:
                            ensure => '1.0.1-4ubuntu5.35';
                    }
                }
                14.04: {
                    realize(Packages::Aptrepo['openssl'])
                    package {
                        ['openssl', 'libssl1.0.0', 'libssl-dev']:
                            ensure => '1.0.1f-1ubuntu2.18';
                    }
                }
                16.04: {
                    package {
                        ['openssl', 'libssl1.0.0', 'libssl-dev']:
                            ensure => '1.0.2g-1ubuntu4.6';
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }

        Windows: {
            packages::pkgzip {
                'openssl-09.8h-1-win32-exe.zip':
                    zip        => 'openssl-09.8h-1-win32-exe.zip',
                    target_dir => '"C:\Program Files (x86)"';
                'openssl-09.8h-1-win32-dll.zip':
                    zip        => 'openssl-09.8h-1-win32-dll.zip',
                    target_dir => '"C:\Windows\System32"';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
