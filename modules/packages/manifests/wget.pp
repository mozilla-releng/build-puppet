# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::wget {
    anchor {
        'packages::wget::begin': ;
        'packages::wget::end': ;
    }

    case $::operatingsystem {
        CentOS, Ubuntu: {
            Anchor['packages::wget::begin'] ->
            package {
                "wget":
                    ensure => latest;
            } -> Anchor['packages::wget::end']
        }
        Darwin: {
            Anchor['packages::wget::begin'] ->
            packages::pkgdmg {
                wget:
                    version => "1.12-1";
            } -> Anchor['packages::wget::end']
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
