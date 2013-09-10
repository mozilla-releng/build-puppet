# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::gstreamer {
    case $::operatingsystem {
        Ubuntu: {
            package {
                ["gstreamer0.10-ffmpeg", "gstreamer0.10-plugins-base",
                 "gstreamer0.10-plugins-good", "gstreamer0.10-plugins-ugly",
                 # plugins-bad contains a libfaad-based AAC decoder that will make
                 # tests succeed - see bug 912854
                 "gstreamer0.10-plugins-bad"]:
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
