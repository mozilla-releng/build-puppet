# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent::disable {

    $mig_path = $::operatingsystem ? { /(CentOS|Ubuntu)/ => '/sbin/mig-agent', Darwin => '/usr/local/bin/mig-agent' }
    case $::operatingsystem {
        # We want to disable mig-agent on Linux and MacOS workers
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04: {
                    # Kill mig agent service if it is running
                    exec {
                        'kill mig':
                            command   => "/bin/kill -s 2 $(${mig_path} -q=pid)",
                            subscribe => Class['packages::mozilla::mig_agent'],
                            notify    => Service['mig-agent']
                    }
                    service {
                        'mig-agent':
                            ensure   => stopped,
                            enable   => false,
                            provider => 'systemd'
                    }
                }
            }
        }
        Darwin {
            # Kill the process
            exec {
                'kill mig':
                    command   => "/bin/kill -s 2 $(${mig_path} -q=pid)",
                    subscribe => Class['packages::mozilla::mig_agent'],
                    notify    => Service['mig-agent']
            }
            # Remove the package
            file {'/var/db/.mig-agent':
                ensure => 'absent',
                force  => true,
            }
        }
    }
}
