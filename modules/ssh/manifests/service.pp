# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ssh::service {
    case $::operatingsystem {
        CentOS : {
            service {
                'sshd':
                    ensure => 'running',
                    enable => true;
            }
        }
        Windows : {
            include packages::kts

            # this installs the service which puppet subsequently manages
            shared::execonce {
                'Install-SSH-service':
                    command => '"C:\Program Files\KTS\daemon.exe" -install',
                    require => Class['packages::kts'];
            }
            service {
                'KTS':
                    ensure  => running,
                    enable  => true,
                    require => [Shared::Execonce['Install-SSH-service'],
                                    Class['ssh::config']
                                ];
            }
        }

        Darwin : {
            exec {
                # Using -w will enable the service for future boots, this
                # command does tick the box for remote-login in the Sharing
                # prefpane (survives reboot)
                'turn-on-ssh' :
                    command =>
                    '/bin/launchctl load -w /System/Library/LaunchDaemons/ssh.plist',
                    unless  =>
                    "/usr/sbin/netstat -na | /usr/bin/grep -q 'tcp4.*\\*.22.*LISTEN'";
            }

            # Delete the com.apple.access_ssh group.  If present, this group limits
            # SSH logins to those in the group, but without it, any user can log in.
            group {
                'com.apple.access_ssh':
                    ensure => absent;
            }
        }
    }
}
