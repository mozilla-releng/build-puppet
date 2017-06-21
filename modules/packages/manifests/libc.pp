# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::libc {
    case $::operatingsystem {
        CentOS: {
            case $::operatingsystemrelease {
                6.5: {
                    realize(Packages::Yumrepo['glibc'])
                    package {
                        'glibc':
                            ensure => '2.12-1.166.el6_7.7';
                    }
                }
                6.2: {
                    # still vulnerable - Bug 1126428
                }
                default: {
                    fail("Unsupported CentOS version ${::operatingsystemrelease}")
                }
            }
        }

        Darwin: {
            # default version is fine
        }

        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    realize(Packages::Aptrepo['eglibc'])
                    package {
                        'libc6':
                            ensure => '2.15-0ubuntu10.13';
                    }
                }
                14.04: {
                    realize(Packages::Aptrepo['eglibc'])
                    package {
                        'libc6':
                            ensure => '2.19-0ubuntu6.7';
                    }
                }
                default: {
                    # default version is fine
                    package {
                        'libc6':
                            ensure => present;
                    }
                }
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

