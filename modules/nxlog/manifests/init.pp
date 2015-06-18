# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class nxlog {
    case $::operatingsystem {
        Windows: {
            include packages::nxlog
            include nxlog::conf
            include nxlog::svc
        }
        default: {
            fail('Cannot set up NXLog on this platform')
        }
    }
}
