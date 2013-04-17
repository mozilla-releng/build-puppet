# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# ia32-libs are needed by b2g emulator tests
class packages::ia32libs {
    case $::operatingsystem {
        Ubuntu: {
            case $::hardwaremodel {
                "x86_64": {
                    package {
                        "ia32-libs":
                            ensure => latest;
                    }
                }
            }
        }
        CentOS: {
            case $::hardwaremodel {
                "x86_64": {
                    package {
                        "libstdc++.i686":
                            ensure => latest;
                        "zlib.i686":
                            ensure => latest;
                    }
                }
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
