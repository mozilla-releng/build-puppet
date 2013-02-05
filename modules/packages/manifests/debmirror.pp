# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::debmirror {
    case $::operatingsystem {
        CentOS: {
            package {
                "debmirror":
                    # NOTE: this RPM is currently in the 'releng' repo, because
                    # it was not present in the version of EPEL last mirrored.
                    # It is now present in EPEL, so on the next EPEL mirroring,
                    # the version in the releng repo can be deleted.
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
