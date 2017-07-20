# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xcode {
    anchor {
        'packages::xcode::begin': ;
        'packages::xcode::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            # Different versions of OS X use different versions of Xcode.  And
            # every version of Xcode is its own unique little hell.  Of course,
            # we can't distribute Xcode, but the instructions here should be
            # sufficient to reproduce what we've done.  Note that Apple
            # frequently deletes "old" stuff, so you may not be able to find
            # some of the source binaries anymore.  Sorry.  Apple sucks.
            case $::config::xcode_version {
                '4.1': {
                    # This is a re-packaged version of Xcode 4.1.  Here's how to build it:
                    # install the Xcode DMG, which just installs "Install Xcode" into /Applications
                    #   mkdir /tmp/dmg
                    #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Xcode.mpkg /tmp/dmg/Xcode.mpkg
                    #   ditto /Applications/Install\ Xcode.app/Contents/Resources/Packages /tmp/dmg/Packages
                    #   makehybrid -hfs -hfs-volume-name 'mozilla-repack-xcode-4.1' -o ./xcode-4.1.dmg /tmp/dmg/
                    Anchor['packages::xcode::begin'] ->
                    packages::pkgdmg {
                        'xcode':
                            version             => '4.1',
                            os_version_specific => false,
                            private             => true;
                    } -> Anchor['packages::xcode::end']
                }

                '5.1-cmdline': {
                    case $::macosx_productversion_major {
                        10.8: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                'command_line_tools_for_osx_mountain_lion_april_2014':
                                    version => '5.1',
                                    private => true,
                                    dmgname => 'command_line_tools_for_osx_mountain_lion_april_2014.dmg';
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${::macosx_productversion_major}")
                        }
                    }
                }

                '4.6.2-cmdline': {
                    # this might work on other OS X versions, but hasn't been tested
                    case $::macosx_productversion_major {
                        10.7: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                'xcode462_cltools_10_76938260a':
                                    version => '4.6.2',
                                    private => true,
                                    dmgname => 'xcode462_cltools_10_76938260a.dmg';
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${::macosx_productversion_major}")
                        }
                    }
                }

                '5.0-cmdline': {
                    # N.B. This is the dev preview and should be upgraded before use!
                    case $::macosx_productversion_major {
                        10.9: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                'command_line_tools_for_os_x_mavericks_developer_preview_4':
                                    version => '5.0',
                                    private => true,
                                    dmgname => 'command_line_tools_for_os_x_mavericks_developer_preview_4.dmg';
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${::macosx_productversion_major}")
                        }
                    }
                }

                '6.1-cmdline': {
                    # N.B. This is the dev preview and should be upgraded before use!
                    case $::macosx_productversion_major {
                        10.9,10.10: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgdmg {
                                'command_line_tools_for_osx_10.10_for_xcode_6.1_gm_seed_2':
                                    version => '6.1',
                                    private => true,
                                    dmgname => 'command_line_tools_for_osx_10.10_for_xcode_6.1_gm_seed_2.dmg';
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${::macosx_productversion_major}")
                        }
                    }
                }

                '6.1': {
                    case $::macosx_productversion_major {
                        10.10: {
                            Anchor['packages::xcode::begin'] ->
                            packages::pkgappdmg {
                                'xcode-6.1':
                                    version => '6.1',
                                    private => true,
                                    dmgname => 'xcode-6.1.dmg';
                            } ->
                            shared::execonce { 'xcode_license_agree':
                                command => '/usr/bin/xcodebuild -license accept',
                            } -> Anchor['packages::xcode::end']
                        }
                        default: {
                            fail("cannot install XCode ${::config::xcode_version} ${::macosx_productversion_major}")
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
