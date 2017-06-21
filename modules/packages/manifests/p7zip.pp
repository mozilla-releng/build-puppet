# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::p7zip {
    anchor {
        'packages::p7zip::begin': ;
        'packages::p7zip::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            package {
                'p7zip':
                    ensure => latest;
            }
        }
        Darwin: {
            Anchor['packages::p7zip::begin'] ->
            packages::pkgdmg {
                'p7zip':
                    # this DMG came from the old releng puppet.  Its provenance is unknown.
                    version => '9.20.1';
            } -> Anchor['packages::p7zip::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
