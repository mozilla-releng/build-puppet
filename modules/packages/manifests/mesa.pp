# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mesa {
    case $::operatingsystem {
        Ubuntu: {
            realize(Packages::Aptrepo['mesa-lts-saucy'])
            case $::hardwaremodel {
                'i686': {
                    package {
                      # This package is a recompiled version of
                      # http://packages.ubuntu.com/precise-updates/mesa-common-dev-lts-saucy
                      # with some additional patches
                      ['libgl1-mesa-dev-lts-saucy',
                      'libgl1-mesa-dri-lts-saucy',
                      'libgl1-mesa-glx-lts-saucy',
                      'libxatracker1-lts-saucy',
                      'libglapi-mesa-lts-saucy',
                      'libgl1-mesa-dri-lts-saucy-dbg',
                      'mesa-common-dev-lts-saucy']:
                        ensure => '9.2.1-1ubuntu3~precise1mozilla2';
                    }
                }
                'x86_64': {
                    package {
                      # This package is a recompiled version of
                      # http://packages.ubuntu.com/precise-updates/mesa-common-dev-lts-saucy
                      # with some additional patches
                      # libgl1-mesa-dev-lts-saucy:i386 is required by B2G emulators, Bug 1013634
                      ['libgl1-mesa-dev-lts-saucy:i386',
                      'libgl1-mesa-dri-lts-saucy',
                      'libgl1-mesa-dri-lts-saucy:i386',
                      'libgl1-mesa-glx-lts-saucy',
                      'libgl1-mesa-glx-lts-saucy:i386',
                      'libglapi-mesa-lts-saucy',
                      'libglapi-mesa-lts-saucy:i386',
                      'libxatracker1-lts-saucy',
                      'libgl1-mesa-dri-lts-saucy-dbg',
                      'libgl1-mesa-dri-lts-saucy-dbg:i386',
                      'mesa-common-dev-lts-saucy:i386']:
                        ensure => '9.2.1-1ubuntu3~precise1mozilla2';
                    }
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
