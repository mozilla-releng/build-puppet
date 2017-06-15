# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class cron {
    include packages::crond

    case $::operatingsystem {
        CentOS: {
            service {
                'crond':
                    ensure  => 'running',
                    enable  => true,
                    require => Class['packages::crond'];
            }
        }
        Ubuntu: {
            service {
                'cron':
                    ensure  => 'running',
                    enable  => true,
                    require => Class['packages::crond'];
            }
        }
        Darwin: {
            # launchd takes the place of cron here
        }

        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
