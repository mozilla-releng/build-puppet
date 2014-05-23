# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xcode {
    anchor {
        'packages::xcode::begin': ;
        'packages::xcode::end': ;
    }

    case $operatingsystem {
        Darwin: {
            # Different versions of OS X use different versions of Xcode.  And
            # every version of Xcode is its own unique little hell.  Of course,
            # we can't distribute Xcode, but the instructions here should be
            # sufficient to reproduce what we've done.  Note that Apple
            # frequently deletes "old" stuff, so you may not be able to find
            # some of the source binaries anymore.  Sorry.  Apple sucks.
            case $::config::xcode_version {
                "4.1": {
                    # This is a re-packaged version of Xcode 4.1.  Here's how to build it:
                    # install the Xcode DMG, which just installs "Install Xcode" into /Applications
                    #   mkdir /tmp/dmg
                    #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Xcode.mpkg /tmp/dmg/Xcode.mpkg
                    #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Packages /tmp/dmg/Packages
                    #   makehybrid -hfs -hfs-volume-name "mozilla-repack-xcode-4.1" -o ./xcode-4.1.dmg /tmp/dmg/
                    Anchor['packages::xcode::begin'] ->
                    packages::pkgdmg {
                        "xcode":
                            version => "4.1",
                            os_version_specific => false,
                            private => true;
                    } -> Anchor['packages::xcode::end']
                }

                "4.2": {
                    case $macosx_productversion_major {
                        '10.6': { # Xcode-4.2
                            # This is based on the download of Xcode-4.2 for snow
                            # leopard, which required (requires?) a paid dev account.
                            # Mount it:
                            #   hdiutil attach foo.dmg
                            # and then strip the certs using the script in the same dir
                            # as this .pp file:
                            #   xcode-remove-certs.sh
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                'xcode':
                                    version => '4.2',
                                    dmgname => 'xcode-with-certs-stripped-4.2.dmg',
                                    private => true;
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${macosx_productversion_major}")
                        }
                    }
                }

                "4.5-cmdline": {
                    case $::macosx_productversion_major {
                        10.8: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                "command_line_tools_for_xcode_4.5_os_x_mountain_lion":
                                    version => "4.5",
                                    private => true,
                                    dmgname => "command_line_tools_for_xcode_4.5_os_x_mountain_lion.dmg";
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${macosx_productversion_major}")
                        }
                    }
                }
                
                "4.6.2-cmdline": {
                    # this might work on other OS X versions, but hasn't been tested
                    case $::macosx_productversion_major {
                        10.7: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                "xcode462_cltools_10_76938260a":
                                    version => "4.6.2",
                                    private => true,
                                    dmgname => "xcode462_cltools_10_76938260a.dmg";
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${macosx_productversion_major}")
                        }
                    }
                }

                "5.0-cmdline": {
                    # N.B. This is the dev preview and should be upgraded before use!
                    case $::macosx_productversion_major {
                        10.9: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                "command_line_tools_for_os_x_mavericks_developer_preview_4":
                                    version => "5.0",
                                    private => true,
                                    dmgname => "command_line_tools_for_os_x_mavericks_developer_preview_4.dmg";
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${macosx_productversion_major}")
                        }
                    }
                }

                default: {
                    fail("unknown XCode version ${::config::xcode_version}")
                }
            }
        }
    }
}
