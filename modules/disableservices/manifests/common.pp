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
                [
                    # bluetooth keyboard prompt
                    'com.apple.blued',
                    # periodic software update checks
                    'com.apple.softwareupdatecheck.initial', 'com.apple.softwareupdatecheck.periodic',
                ]:
                    enable => false,
                    ensure => stopped,
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
                "$settings::vardir/.puppet-indexing" :
                    content => "indexing-disabled",
                    notify => Exec["disable-indexing", "remove-index"] ;
            }
        }
    }
}
