# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent::disable {

    $mig_path = $::operatingsystem ? { /(CentOS|Ubuntu)/ => '/sbin/mig-agent', Darwin => '/usr/local/bin/mig-agent' }
    case $::operatingsystem {
        CentOS: {
            file {
                '/etc/init/mig-agent.conf':
                    ensure => absent;
                '/etc/mig':
                    ensure => absent,
                    force  => true;
                "${mig_path}":
                    ensure => absent;
            }
            exec { 'kill mig':
                command => "/usr/bin/pkill -9 mig-agent",
                onlyif  => "/usr/bin/pgrep mig-agent",
            }
        }
        # We want to disable mig-agent on Linux and MacOS workers
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04: {
                    # Stop teh mig agent service
                    service {
                        'mig-agent':
                            ensure   => stopped,
                            enable   => false,
                            provider => 'systemd'
                    }
                    # remove the package from the worker
                    package {'mig-agent':
                        ensure => absent
                    }
                    # Remove mig configuration file and keys
                    # Configuration file and keys are stored in /etc/mig directory
                    file {'/etc/mig':
                        ensure => absent,
                        force  => true,
                    }
                }
            }
        }
        Darwin: {
            # Kill the process, if mig-agent is running
            exec {
                'kill mig':
                    command => "/usr/bin/pkill -9 mig-agent",
                    onlyif  => "/usr/bin/pgrep mig-agent",
            } ->
            # Remove the flag that puppet sets indicating the package has been installed.
            file {'/var/db/.puppet_pkgdmg_installed_mig-agent-20180807-0.e8eb90a1.prod-x86_64.dmg':
                ensure => 'absent',
                force  => true,
            } ->
            # Remove mig configuration file and keys
            # Configuration file and keys are stored in /etc/mig directory
            file {'/etc/mig':
                ensure => absent,
                force  => true,
            }->
            # Remove executable
            file {"${mig_path}":
                ensure => 'absent'
            }->
            # Remove launchd plist file
            file {'/Library/LaunchDaemons/mig-agent.plist':
                ensure => 'absent'
            }
        }
    }
}
