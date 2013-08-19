# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xcode_cmdline_tools {

  # the dmg is available from https://developer.apple.com/downloads

    anchor {
        'packages::xcode_cmdline_tools::begin': ;
        'packages::xcode_cmdline_tools::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            case $::macosx_productversion_major {
                10.8: {
                    Anchor['packages::xcode_cmdline_tools::begin'] ->
                    packages::pkgdmg {
                        "command_line_tools_for_xcode_4.5_os_x_mountain_lion":
                            version => "4.5",
                            private => true,
                            dmgname => "command_line_tools_for_xcode_4.5_os_x_mountain_lion.dmg";
                    } -> Anchor['packages::xcode_cmdline_tools::end']
                }
                default: {
                    fail("cannot install on OS X $::macosx_productversion_major")
                }
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }

}
