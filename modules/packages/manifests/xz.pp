# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xz {
    case $::operatingsystem {
        Darwin: {
            packages::pkgdmg {
                'xz':
                    version             => '5.2.3',
                    os_version_specific => false,
                    private             => false;
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
