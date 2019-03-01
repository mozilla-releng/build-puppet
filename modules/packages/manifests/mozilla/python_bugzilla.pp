# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::python_bugzilla {

    anchor {
        'packages::mozilla::python_bugzilla::begin': ;
        'packages::mozilla::python_bugzilla::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            case $::macosx_productversion_major {
                '10.10': {
                    # Install python-bugzilla on OSX workers
                    Anchor['packages::mozilla::python_bugzilla::begin'] ->
                    packages::pkgdmg {
                        'python-bugzilla':
                            os_version_specific => true,
                            version             => '2.2.0-1';
                    }  -> Anchor['packages::mozilla::python_bugzilla::end']
                }
                default: {
                    fail("Cannot install on Darwin version ${::macosx_productversion_major}")
                }
            }
        }
        Ubuntu: {
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
