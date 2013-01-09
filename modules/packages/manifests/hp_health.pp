# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::hp_health {
    realize(Packages::Yumrepo['hp-proliantsupportpack'])

    case $::operatingsystem {
        CentOS: {
            package {
                "hp-health":
                    ensure => latest;
                # this isn't listed as a prereq, but this utility needs the i386 lib
                # to run successfully
                "libgcc.i686":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
