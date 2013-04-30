# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nrpe {
    case $::operatingsystem {
        CentOS: {
            package {
                "nrpe":
                    ensure => latest;
                "nagios-plugins-nrpe":
                    ensure => latest;
                "nagios-plugins-all":
                    ensure => latest;
            }
        }
        Darwin: {
            packages::pkgdmg {
                nrpe:
                    # this package was copied from the old releng puppet; its
                    # provenance is unknown.  Note that this does *not* set up the
                    # corresponding user, nor set the service to start at boot.
                    # That will wait for a well-defined DMG.
                    version => "2.6";
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
