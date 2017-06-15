# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class generic_worker::disabled {

    case $::operatingsystem {
        Darwin: {
            file { '/Library/LaunchAgents/net.generic.worker.plist':
                ensure => absent,
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

