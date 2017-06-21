# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::autoconf {
    anchor {
        'packages::autoconf::begin': ;
        'packages::autoconf::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            Anchor['packages::autoconf::begin'] ->
            packages::pkgdmg {
                'autoconf':
                    version => '2.13';
            } -> Anchor['packages::autoconf::end']
        }
        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
