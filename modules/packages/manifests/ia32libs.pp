# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# ia32-libs are needed by b2g emulator tests
class packages::ia32libs {
    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                12.04: {
                    case $::hardwaremodel {
                        'x86_64': {
                            package {
                                'ia32-libs':
                                    ensure => latest;
                            }
                        }
                    }
                }
                16.04: {
                    # In ubuntu 16.04, ia32-libs was replaced with lib32z1 lib32ncurses5
                    # When I tried to install ia32-libs, I received the error:
                    # However the following packages replace it:
                    # lib32z1 lib32ncurses5
                    case $::hardwaremodel {
                        'x86_64': {
                            package {
                                'lib32ncurses5':
                                    ensure => '6.0+20160213-1ubuntu1';
                            }
                        }
                    }
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        CentOS: {
            case $::hardwaremodel {
                'x86_64': {
                    package {
                        'libstdc++.i686':
                            ensure => latest;
                        'zlib.i686':
                            ensure => latest;
                    }
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
