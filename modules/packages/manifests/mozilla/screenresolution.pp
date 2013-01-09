# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::screenresolution {
    anchor {
        'packages::mozilla::screenresolution::begin': ;
        'packages::mozilla::screenresolution::end': ;
    }

    Anchor['packages::mozilla::screenresolution::begin'] ->
    case $::operatingsystem {
        CentOS : {
            # doesn't apply
        }
        Darwin : {
             packages::pkgdmg {
                screenresolution:
                    version => "1.6";
             }
        }
        default : {
            fail("cannot install on $::operatingsystem")
        }
    } -> Anchor['packages::mozilla::screenresolution::end']
}
