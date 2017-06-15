# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw {
    # compatibility check..
    case $::operatingsystem {
        CentOS, Ubuntu: {
            # ok!
        }
        default: {
            fail("'fw' is not supported on this platform")
        }
    }

    include fw::pre
    include fw::post
}
