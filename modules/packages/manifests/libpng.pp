# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::libpng {
    anchor {
        'packages::libpng::begin': ;
        'packages::libpng::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            Anchor['packages::libpng::begin'] ->
            packages::pkgdmg {
                'libpng':
                    version => '1.6.2';
            } -> Anchor['packages::libpng::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
