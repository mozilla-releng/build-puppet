# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::xvfb {
    case $::operatingsystem {
        CentOS: {
            package {
                'xorg-x11-server-Xvfb':
                    ensure => latest;
                'xorg-x11-xauth':
                    ensure => latest;
            }
        }
        Ubuntu: {
            package {
                ['xauth', 'xvfb']:
                    ensure => latest;
            }
        }
        Darwin: {
            # N/A
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
