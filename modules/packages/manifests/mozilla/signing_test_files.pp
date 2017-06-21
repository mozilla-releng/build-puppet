# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::signing_test_files {
    anchor {
        'packages::mozilla::signing_test_files::begin': ;
        'packages::mozilla::signing_test_files::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            Anchor['packages::mozilla::signing_test_files::begin'] ->
            package {
                'mozilla-signing-test-files':
                    ensure => '1.2-1';
            } -> Anchor['packages::mozilla::signing_test_files::end']
        }
        Darwin: {
            Anchor['packages::mozilla::signing_test_files::begin'] ->
            packages::pkgdmg {
                'signing_test_files':
                    version             => '1.0-1',
                    os_version_specific => false;
            } -> Anchor['packages::mozilla::signing_test_files::end']
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
