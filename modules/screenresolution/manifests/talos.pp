# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class screenresolution::talos {
    $width = 1600
    $height = 1200
    $depth = 32
    # 24==32 for Xvfb
    $xvfb_depth = 24
    $refresh = 60

    case $::operatingsystem {
        Darwin: {
            include packages::mozilla::screenresolution
            $resolution = "${width}x${height}x${depth}@${refresh}"

            # this can't run while puppetizing, since the automatic login isn't in place yet, and
            # the login window does not allow screenresolution to run.
            if (!$puppetizing) {
                exec {
                    "set-resolution":
                        command => "/usr/local/bin/screenresolution set $resolution",
                        unless => "/usr/local/bin/screenresolution get 2>&1 | /usr/bin/grep 'Display 0: $resolution'",
                        require => Class["packages::mozilla::screenresolution"];
                }
            }
        }
        Ubuntu: {
            # Ubuntu uses the class variables defined above in the configs
        }
        default: {
            fail("Don't have a mechanism to set screen resolution on $::operatingsystem")
        }
    }
}
