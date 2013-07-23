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
            # different versions work for different OS X versions, yuck
            case $::macosx_productversion_major {
                '10.6','10.7': {
                    packages::pkgdmg {
                        screenresolution:
                            version => "1.5";
                    }
                }
                '10.8': {
                    packages::pkgdmg {
                        screenresolution:
                            version => "1.6";
                    }
                }
                default: {
                    fail("no build of screenresolution known to work on this OS X version")
                }
            }
        }
        default : {
            fail("cannot install on $::operatingsystem")
        }
    } -> Anchor['packages::mozilla::screenresolution::end']
}
