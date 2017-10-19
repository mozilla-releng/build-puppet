# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::openssl_non_xcode {

    anchor {
        'packages::openssl_non_xcode::begin': ;
        'packages::openssl_non_xcode::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            Anchor['packages::openssl_non_xcode::begin'] ->
            packages::pkgdmg {
                'openssl':
                    version             => '1.0.2l',
                    os_version_specific => true,
                    private             => false;
            } -> Anchor['packages::openssl_non_xcode::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
