# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::common {
    # This class disables unnecessary services common to both server and slave

    case $::operatingsystem {
        CentOS : {
            service {
                ['acpid', 'anacron', 'apmd', 'atd', 'autofs',
                'avahi-daemon', 'avahi-dnsconfd', 'bluetooth',
                'cups', 'cups-config-daemon', 'gpm', 'hidd', 'hplip',
                'kudzu', 'mcstrans', 'mdmonitor', 'pcscd',
                'restorecond', 'rpcbind', 'rpcgssd', 'rpcidmapd',
                'sendmail', 'smartd', 'vncserver', 'yum-updatesd'] :
                    ensure => stopped,
                    enable => false;
                'cpuspeed' :
                    enable => false;
            }
        }
        Ubuntu: {
            # These packages are required by ubuntu-desktop, so we can't uninstall them.  Instead,
            # install but disable them.
            case $::operatingsystemrelease {
                12.04,14.04: {
                    $install_and_disable = [ 'cups', 'anacron', 'whoopsie', 'lightdm',
                        'modemmanager', 'apport', 'acpid',
                        'avahi-daemon', 'network-manager' ]
                    package {
                        $install_and_disable:
                            ensure => latest;
                    }
                    service {
                        $install_and_disable:
                            ensure  => stopped,
                            enable  => false,
                            require => Package[$install_and_disable];
                    }

                    # this package and service have different names
                    package {
                        'bluez':
                            ensure => latest;
                    }
                    service {
                        'bluetooth':
                            ensure  => stopped,
                            enable  => false,
                            require => Package['bluez'];
                    }
                }
                16.04: {
                    # For operatingsystem == ubuntu and operatingsystemmajrelease == 15.04, 15.10, 16.04, 16.10, The system management
                    # is realized by systemd and not Upstart
                    $install_and_disable = [ 'cups', 'anacron', 'whoopsie', 'lightdm',
                        'modemmanager', 'apport', 'acpid',
                        'avahi-daemon', 'network-manager' ]
                    package {
                        $install_and_disable:
                            ensure => latest;
                    }
                    service {
                        $install_and_disable:
                            ensure   => stopped,
                            provider => 'systemd',
                            enable   => false,
                            require  => Package[$install_and_disable];
                    }

                    # this package and service have different names
                    package {
                        'bluez':
                            ensure => latest;
                    }
                    service {
                        'bluetooth':
                            ensure   => stopped,
                            provider => 'systemd',
                            enable   => false,
                            require  => Package['bluez'];
                    }
                }
                default: {
                    fail("Unrecognized Ubuntu version ${::operatingsystemrelease}")
                }
            }
        }
        Darwin : {
            service {
                # bluetooth keyboard prompt
                'com.apple.blued':
                    ensure => stopped,
                    enable => false,
            }
            case $::macosx_productversion_major {
                # 10.6 doesn't seem to have a way to disable software update, but later versions do
                10.6: {}
                10.7, 10.8: {
                    service {
                        [
                            'com.apple.softwareupdatecheck.initial',
                            'com.apple.softwareupdatecheck.periodic',
                        ]:
                            ensure => stopped,
                            enable => false,
                    }
                }
                10.9, 10.10: {
                    service {
                        [
                            'com.apple.softwareupdated',
                            'com.apple.systemstatsd',
                            'com.apple.systemstats.daily',
                            'com.apple.systemstats.analysis',
                            'com.apple.metadata.mds',
                            'com.apple.metadata.mds.index',
                            'com.apple.metadata.mds.scan',
                            'com.apple.metadata.mds.spindump',
                        ]:
                            ensure => stopped,
                            enable => false,
                    }
                }
            }
            exec {
                'disable-indexing' :
                    command     => '/usr/bin/mdutil -a -i off',
                    refreshonly => true ;
                'remove-index' :
                    command     => '/usr/bin/mdutil -a -E',
                    refreshonly => true ;
                'disable-panic-reporting':
                    command => '/bin/launchctl unload -w /System/Library/LaunchAgents/com.apple.ReportPanic.plist',
                    onlyif  => "/bin/launchctl list | /usr/bin/grep -q 'com.apple.ReportPanic$'";
                'disable-panic-reporting-service':
                    command => '/bin/launchctl unload -w /System/Library/LaunchDaemons/com.apple.ReportPanicService.plist',
                    onlyif  => "/bin/launchctl list | /usr/bin/grep -q 'com.apple.ReportPanicService$'";
            }
            osxutils::defaults {
            # set the global preference to not start bluetooth mouse assistant
            'disable-bluetooth-mouse':
                domain => '/Library/Preferences/com.apple.Bluetooth',
                key    => 'BluetoothAutoSeekPointingDevice',
                value  => '0';
            }
            osxutils::defaults {
            # set the global preference to not start bluetooth keyboard assistant
                'disable-bluetooth-keyboard':
                    domain => '/Library/Preferences/com.apple.Bluetooth',
                    key    => 'BluetoothAutoSeekKeyboard',
                    value  => '0';
            }
            osxutils::defaults {
                # set the global preference to not restart apps open before reboot
                'disable-relaunch-apps':
                    domain => '/Library/Preferences/com.apple.loginwindow',
                    key    => 'LoginwindowLaunchesRelaunchApps',
                    value  => '0';
            }
            file {
                '/var/lib/puppet/.indexing-disabled' :
                    content => 'indexing-disabled',
                    notify  => Exec['disable-indexing', 'remove-index'] ;
            }
        }
        Windows: {
            include disableservices::disableupdates
            include disableservices::disableddns
            include disableservices::winreport
        }
    }
}
