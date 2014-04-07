# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::libxcb1 {
    case $::operatingsystem {
        Ubuntu: {
            case $::hardwaremodel {
                "x86_64": {
                    # These packages have to be installed in a single transation, see bugs 975216 and 991274
                    exec {
                        "install-libxcb1":
                            command => "/usr/bin/apt-get -q -y -o DPkg::Options::=--force-confold --force-yes install libxcb1:i386=1.8.1-2ubuntu2.1mozilla1 libxcb-glx0=1.8.1-1 libxcb-glx0:i386=1.8.1-1 libxcb-render0=1.8.1-1 libxcb-render0:i386=1.8.1-1 libxcb-shm0=1.8.1-1 libxcb-shm0:i386=1.8.1-1 libxcb-glx0=1.8.1-1 && /bin/touch /var/lib/dpkg/install-libxcb1.done",
                            creates => "/var/lib/dpkg/install-libxcb1.done";
                    }
                }
                default: {
                    package {
                        "libxcb1":
                            ensure => "1.8.1-2ubuntu2.1mozilla1";
                    }
                }
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
