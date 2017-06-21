# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::crond {
    case $::operatingsystem {
        CentOS: {
            package {
                'cronie':
                    ensure => latest;
            }
        }

        Ubuntu: {
            package {
                'cron':
                    ensure => latest;
            }
        }

        Darwin: {
            # launchd takes the place of cron here
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

