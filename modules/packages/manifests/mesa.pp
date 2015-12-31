# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mesa {
    case $::operatingsystem {
        Ubuntu: {
            realize(Packages::Aptrepo['precise-updates'])
            realize(Packages::Aptrepo['mesa-lts-saucy'])
            case $::hardwaremodel {
                "i686": {
                    package {
                      # This package is a recompiled version of
                      # http://packages.ubuntu.com/precise-updates/mesa-common-dev-lts-saucy
                      ["libgl1-mesa-dri-lts-saucy", "libgl1-mesa-glx-lts-saucy",
                       "libglapi-mesa-lts-saucy", "libxatracker1-lts-saucy"]:
                         ensure => '9.2.1-1ubuntu3~precise1mozilla1';
                    }
                }
                "x86_64": {
                    package {
                      # This package is a recompiled version of
                      # http://packages.ubuntu.com/precise-updates/mesa-common-dev-lts-saucy
                      # libgl1-mesa-dev-lts-saucy:i386 is required by B2G emulators, Bug 1013634
                      ["libgl1-mesa-dri-lts-saucy", "libgl1-mesa-glx-lts-saucy",
                       "libglapi-mesa-lts-saucy", "libxatracker1-lts-saucy",
                       "libgl1-mesa-dev-lts-saucy:i386"]:
                         ensure => '9.2.1-1ubuntu3~precise1mozilla1';
                    }
                }
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
