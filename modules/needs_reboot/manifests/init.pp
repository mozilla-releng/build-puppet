# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class needs_reboot {
    include needs_reboot::motd

    $command = $::operatingsystem ? {
                windows => 'type nul > C:/REBOOT_AFTER_PUPPET',
                default => 'touch /REBOOT_AFTER_PUPPET',
            }

    exec {
        # ask the puppet startup script to reboot
        'reboot_semaphore':
            command     => $command,
            path        => ['/bin/', '/usr/bin/'],
            refreshonly => true;
    }

    case $::operatingsystem {
        CentOS: {
            file {
                '/etc/init.d/rm_reboot':
                    mode   => '0755',
                    source => 'puppet:///modules/needs_reboot/rm_reboot.init.d',
                    notify => Exec['chkconfig_rm_reboot'];
            }
            exec { 'chkconfig_rm_reboot':
                command     => '/sbin/chkconfig --add rm_reboot',
                refreshonly => true;
            }
        }
        Ubuntu: {
            file {
                '/etc/init/rm_reboot.conf':
                    mode   => '0644',
                    source => 'puppet:///modules/needs_reboot/rm_reboot.upstart.conf';
                '/etc/init.d/rm_reboot':
                    ensure => link,
                    force  => true,
                    target => '/lib/init/upstart-job';
            }
        }
        Darwin: {
            file { '/Library/LaunchDaemons/com.mozilla.rm_reboot.plist':
                mode   => '0644',
                owner  => root,
                group  => wheel,
                source => 'puppet:///modules/needs_reboot/rm_reboot.plist';
            }
        }
        Windows: {
            windowsutils::startup_tasks { 'rm_reboot_semaphore':
                ensure  => present,
                command => 'cmd.exe /c if exist C:\REBOOT_AFTER_PUPPET del /F /Q C:\REBOOT_AFTER_PUPPET';
            }
        }
    }
}
