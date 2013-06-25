# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::hp_health {

# This entire class should be removed soon.  We only keep it here for now
# to ensure the package is removed from currect systems
# https://bugzilla.mozilla.org/show_bug.cgi?id=883318
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['hp-proliantsupportpack'])
            package {
                "hp-health":
                    ensure => absent;
                # this isn't listed as a prereq, but this utility needs the i386 lib
                # to run successfully
                #"libgcc.i686":
                #    ensure => latest;
            }
        }
        Ubuntu: {
            # do nothing for now
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
