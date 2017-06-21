# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::upx {
    anchor {
        'packages::upx::begin': ;
        'packages::upx::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            Anchor['packages::upx::begin'] ->
            packages::pkgdmg {
                'upx':
                    version => '3.05';
            } -> Anchor['packages::upx::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
