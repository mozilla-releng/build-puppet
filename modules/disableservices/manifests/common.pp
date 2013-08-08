# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class disableservices::common {
# This class disables unnecessary services common to both server and slave

    case $::operatingsystem {
        CentOS : {
            service {
                ['acpid', 'anacron', 'apmd', 'atd', 'auditd', 'autofs',
                'avahi-daemon', 'avahi-dnsconfd', 'bluetooth',
                'cups', 'cups-config-daemon', 'gpm', 'hidd', 'hplip', 'kudzu',
                'mcstrans', 'mdmonitor', 'pcscd', 'restorecond', 'rpcgssd',
                'rpcidmapd', 'sendmail', 'smartd', 'vncserver',
                'yum-updatesd'] :
                    enable => false,
                    ensure => stopped;
                'cpuspeed' :
                    enable => false;
            }
        }
        Ubuntu: {
            # These packages are required by ubuntu-desktop, so we can't uninstall them.  Instead,
            # install but disable them.
            $install_and_disable = [ 'cups', 'anacron', 'whoopsie', 'lightdm',
                  'modemmanager', 'apport', 'acpid',
                  'avahi-daemon', 'network-manager' ]
            package {
                $install_and_disable:
                    ensure => latest;
            }
            service {
                $install_and_disable:
                    enable => false,
                    ensure => stopped,
                    require => Package[$install_and_disable];
            }

            # this package and service have different names
            package {
                "bluez":
                    ensure => latest;
            }
            service {
                "bluetooth":
                    enable => false,
                    ensure => stopped,
                    require => Package['bluez'];
            }
        }
        Darwin : {
            service {
                # bluetooth keyboard prompt
                'com.apple.blued':
                    enable => false,
                    ensure => stopped,
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
                            enable => false,
                            ensure => stopped,
                    }
                }
                10.9: {
                    service {
                        'com.apple.softwareupdated':
                            enable => false,
                            ensure => stopped,
                    }
                }
            }
            exec {
                "disable-indexing" :
                    command => "/usr/bin/mdutil -a -i off",
                    refreshonly => true ;
                "remove-index" :
                    command => "/usr/bin/mdutil -a -E",
                    refreshonly => true ;
            }
            osxutils::defaults {
            # set the global preference to not start bluetooth mouse assistant
            'disable-bluetooth-mouse':
                domain => "/Library/Preferences/com.apple.Bluetooth",
                key => "BluetoothAutoSeekPointingDevice",
                value => "0",
                require => Class['users::builder'];
            }
            osxutils::defaults {
            # set the global preference to not start bluetooth keyboard assistant
                'disable-bluetooth-keyboard':
                    domain => "/Library/Preferences/com.apple.Bluetooth",
                    key => "BluetoothAutoSeekKeyboard",
                    value => "0",
                    require => Class['users::builder'];
            }
            file {
                "/var/lib/puppet/.indexing-disabled" :
                    content => "indexing-disabled",
                    notify => Exec["disable-indexing", "remove-index"] ;
            }
            osxutils::defaults {
                'builder-disablescreensaver':
                    domain => "$::users::builder::home/Library/Preferences/ByHost/com.apple.screensaver.$sp_platform_uuid",
                    key => "idleTime",
                    value => "0",
                    require => Class['users::builder'];
            }
            file {
                "$::users::builder::home/Library/Preferences/ByHost":
                    ensure => directory,
                    owner => $::users::builder::username,
                    group => $::users::builder::group,
                    mode => 0700,
                    require => Class['users::builder'];
                "$::users::builder::home/Library/Preferences/ByHost/com.apple.screensaver.$sp_platform_uuid.plist":
                    ensure => file,
                    owner => $::users::builder::username,
                    group => $::users::builder::group,
                    mode => 0600,
                    require => Class['users::builder'];
            }

            # disable Apple's "unsafe files from the internet" warnings
            # http://www.davinian.com/os-x-leopard-are-you-sure-you-want-to-open-it/
            # (as per earlier releng puppet implementations of this).
            file {
                "$::users::builder::home/Library/Preferences/com.apple.DownloadAssessment.plist":
                    source => "puppet:///modules/${module_name}/com.apple.DownloadAssessment.plist",
                    owner => $::users::builder::username,
                    group => $::users::builder::group,
                    mode => 0600,
                    require => Class['users::builder'];
            }
            # and to make double-sure, turn off quarantining:
            # http://superuser.com/questions/38658/how-to-suppress-repetition-of-warnings-that-an-application-was-downloaded-from-t
            osxutils::defaults {
                "builder-disable-quarantine":
                    domain => "$::users::builder::home/Library/Preferences/com.apple.LaunchServices.plist",
                    key => "LSQuarantine",
                    value => "0",
                    require => Class['users::builder'];
            }
        }
    }
}
