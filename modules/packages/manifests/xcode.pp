# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xcode {
    case $operatingsystem {
        Darwin: {
            # This is a re-packaged version of Xcode 4.1.  Here's how to build it:
            # install the Xcode DMG, which just installs "Install Xcode" into /Applications
            #   mkdir /tmp/dmg
            #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Xcode.mpkg /tmp/dmg/Xcode.mpkg
            #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Packages /tmp/dmg/Packages
            #   makehybrid -hfs -hfs-volume-name "mozilla-repack-xcode-4.1" -o ./xcode-4.1.dmg /tmp/dmg/
            packages::pkgdmg {
                "xcode":
                    version => "4.1",
                    private => true;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
