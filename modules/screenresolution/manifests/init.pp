# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class screenresolution($width, $height, $depth, $refresh) {
    case $::operatingsystem {
        Darwin: {
            # set the screen resolution appropriately
            include packages::mozilla::screenresolution

            # the version of screenresolution that works on 10.7 and below doesn't support refresh rates
            case $::macosx_productversion_major {
                10.7: {
                    $resolution = "${width}x${height}x${depth}"
                }
                10.8,10.9: {
                    $resolution = "${width}x${height}x${depth}@${refresh}"
                }
            }

            # this can't run while puppetizing, since the automatic login isn't in place yet, and
            # the login window does not allow screenresolution to run.
            if (!$::puppetizing) {
                exec {
                    'set-resolution':
                        command => "/usr/local/bin/screenresolution set ${resolution}",
                        unless  => "/usr/local/bin/screenresolution get 2>&1 | /usr/bin/grep 'Display 0: ${resolution}'",
                        require => Class['packages::mozilla::screenresolution'];
                }
            }
        }
        default: {
            fail("Cannot manage screen resolution for ${::operatingsystem}")
        }
    }
}
