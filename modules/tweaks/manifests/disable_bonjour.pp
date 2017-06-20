# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# plist, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::disable_bonjour {

    if $::macosx_productversion_major == '10.10' {
        # See bug 1201230 and 1144206
        case $::macosx_productversion {
            # OSX 10.10.[0-3] replaced mDNSResponder with discoveryd
            /10\.10\.[0-3]/: {
                $plist       = 'com.apple.discoveryd'
                $disable_arg = '--no-multicast'
            }
            # OSX 10.10.4+ Apple saw the error of their ways and brought back mDNSResponder
            default: {
                $plist       = 'com.apple.mDNSResponder'
                $disable_arg = '-NoMulticastAdvertisements'
            }
        }

        exec { "${plist}_nomulticast":
            unless  => "/usr/libexec/PlistBuddy -c \"Print :ProgramArguments:\" /System/Library/LaunchDaemons/${plist}.plist | grep \"\\${disable_arg}\"",
            command => "/usr/libexec/PlistBuddy -c \"Add :ProgramArguments: string ${disable_arg}\" /System/Library/LaunchDaemons/${plist}.plist",
        }
    }
}
