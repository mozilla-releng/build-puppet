# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xcode {
    case $operatingsystem {
        Darwin: {
            # Different versions of OS X use different versions of Xcode.  And
            # every version of Xcode is its own unique little hell.  Of course,
            # we can't distribute Xcode, but the instructions here should be
            # sufficient to reproduce what we've done.  Note that Apple
            # frequently deletes "old" stuff, so you may not be able to find
            # some of the source binaries anymore.  Sorry.  Apple sucks.
            case $macosx_productversion_major {
                '10.6': { # Xcode-4.2

                    # This is based on the download of Xcode-4.2 for snow
                    # leopard, which required (requires?) a paid dev account.
                    # Mount it:
                    #   hdiutil attach foo.dmg
                    # and then strip the certs using the script in the same dir
                    # as this .pp file:
                    #   xcode-remove-certs.sh
                    packages::pkgdmg {
                        'xcode':
                            version => '4.2',
                            dmgname => 'xcode-with-certs-stripped-4.2.dmg',
                            private => true;
                    }
                }

                '10.7','10.9': { # Xcode-4.1

                    # This is a re-packaged version of Xcode 4.1.  Here's how to build it:
                    # install the Xcode DMG, which just installs "Install Xcode" into /Applications
                    #   mkdir /tmp/dmg
                    #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Xcode.mpkg /tmp/dmg/Xcode.mpkg
                    #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Packages /tmp/dmg/Packages
                    #   makehybrid -hfs -hfs-volume-name "mozilla-repack-xcode-4.1" -o ./xcode-4.1.dmg /tmp/dmg/
                    # note that this DMG might work on 10.8, too.  It does *not* work on 10.9, at all.
                    packages::pkgdmg {
                        "xcode":
                            version => "4.1",
                            os_version_specific => false,
                            private => true;
                    }
                }

                default: {
                    fail("cannot install on OS X ${macosx_productversion_major}")
                }
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
