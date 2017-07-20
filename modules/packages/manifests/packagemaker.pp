# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::packagemaker {
    case $operatingsystem {
        Darwin: {
            case $macosx_productversion_major {
                10.7, 10.8, 10.9: {
                    # This is a re-packaged version of PackageMaker from the "Late July
                    # 2012" Auxiliary Developer Tools.  Thanks for the detailed version
                    # number, Apple.  The download is named
                    # xcode44auxtools6938114a.dmg, so it's a reasonable guess that this
                    # corresponds to Xcode 4.4.  To reproduce, download from
                    # https://developer.apple.com/downloads/index.action and run the
                    # corresponding shell script in the directory containing this
                    # manifest file.  This version seems to work on 10.7 - 10.9.
                    packages::pkgdmg {
                        'packagemaker':
                            version             => '4.4',
                            os_version_specific => false,
                            private             => true;
                    }
                }
                default: {
                    fail("Cannot install on OS X ${::macosx_productversion_major}")
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
