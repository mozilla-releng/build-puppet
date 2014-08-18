# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::mig_agent {
    include ::config
    if ($::config::enable_mig_agent) {
        case $::operatingsystem {
            'CentOS', 'RedHat': {
                realize(Packages::Yumrepo['mig-agent'])
            }
            'Ubuntu': {
                realize(Packages::Aptrepo['mig-agent'])
            }
        }

        case $::operatingsystem {
            'CentOS', 'RedHat', 'Ubuntu': {
                package {
                    # The package starts the mig-agent service on install
                    # the agent created the necessary service files for (upstart|systemd|sysvinit)
                    # where needed. Agent init process is described at
                    # https://github.com/mozilla/mig/blob/master/doc/concepts.rst
                    'mig-agent':
                        ensure => '201408181131+68245f0.prod-1'
                }
            }
        }
    }
 }
