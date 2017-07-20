# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class vnc {
    include config
    include users::builder
    if ($::operatingsystem != Windows) {
        include packages::vncserver
    }

    case $::operatingsystem {
        Darwin: {
            osxutils::defaults {
                # kickstart -configure -allowAccessFor -allUsers
                ARD_AllLocalUsers:
                    domain => '/Library/Preferences/com.apple.RemoteManagement',
                    key    => 'ARD_AllLocalUsers',
                    value  => '1';
                # kickstart -configure -privs -all -access -on
                # (this doesn't work; see https://bugzilla.mozilla.org/show_bug.cgi?id=733534#c8)
            }

            $kickstart = '/System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart'
            exec {
                #allow builder user to connect via screensharing
                'enable-remote-builduser-access':
                  command     => "${kickstart} -configure -allowAccessFor -specifiedUsers; ${kickstart} -activate -configure -access -on -users ${::users::builder::username} -privs -all -restart -agent -menu",
                  refreshonly => true;
            }
        }
        Ubuntu: {
            if (secret('builder_pw_vnc_cleartext') == '') {
                fail('No VNC password set')
            }
            file {
                "${::users::builder::home}/.vnc":
                    ensure => directory,
                    mode   => '0700',
                    owner  => $::users::builder::username,
                    group  => $::users::builder::group;
                "${::users::builder::home}/.vnc/passwd":
                    ensure => absent;
                '/etc/vnc_passwdfile':
                    ensure    => file,
                    mode      => '0600',
                    owner     => root,
                    group     => root,
                    content   => secret('builder_pw_vnc_cleartext'),
                    show_diff => false;
            }
            case $::operatingsystemrelease {
                12.04,14.04: {
                    file {
                        '/etc/init/x11vnc.conf':
                            content => template("${module_name}/x11vnc.conf.erb");
                        '/etc/init.d/x11vnc':
                            ensure => link,
                            target => '/lib/init/upstart-job';
                    }
                }
                16.04: {
                    file {
                        '/lib/systemd/system/x11vnc.service':
                            content => template("${module_name}/x11vnc.service.erb");
                    }
                }
                default: {
                    fail ("Ubuntu ${::operatingsystemrelease} is not suported")
                }
            }
            # note that x11vnc isn't started automatically
        }
        Windows: {
            include packages::ultravnc
            include vnc::ultravnc_ini
        }
        default: {
            fail('Cannot set up VNC on this platform')
        }
    }
}
