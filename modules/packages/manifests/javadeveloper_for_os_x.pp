# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::javadeveloper_for_os_x {

  anchor {
        'packages::javadeveloper_for_os_x::begin': ;
        'packages::javadeveloper_for_os_x::end': ;
    }

    case $::operatingsystem {
        Darwin: {
            # the dmg is available from https://developer.apple.com/downloads
            case $::macosx_productversion_major {
                '10.8', '10.10': {
                    Anchor['packages::javadeveloper_for_os_x::begin'] ->
                    packages::pkgdmg {
                        'java_for_os_x_2013005_dp__11m4609':
                            version             => '2013005_dp__11m4609',
                            private             => true,
                            os_version_specific => false,
                            dmgname             => 'java_for_os_x_2013005_dp__11m4609.dmg';
                    }-> Anchor['packages::javadeveloper_for_os_x::end']
                }
                default: {
                    Anchor['packages::javadeveloper_for_os_x::begin'] ->
                    packages::pkgdmg {
                        'javadeveloper_for_os_x_2012003__11m3646':
                            version             => '2012003__11m3646',
                            private             => true,
                            os_version_specific => false, # I don't actually know.. --dustin
                            dmgname             => 'javadeveloper_for_os_x_2012003__11m3646.dmg';
                    }-> Anchor['packages::javadeveloper_for_os_x::end']
                }
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

