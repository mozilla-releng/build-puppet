# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class vnc::appearance {

    include dirs::usr::local::bin
    include users::root

    case $::operatingsystem {
        Darwin: {
            if (!$puppetizing) {
                exec {
                    "set-background-image" :
                        command => "/bin/bash /usr/local/bin/changebackground.sh",
                        unless => "/usr/bin/defaults read com.apple.desktop Background | egrep 'Solid Aqua Blue.png'",
                        notify => Exec["restart-Dock"] ;
                    "restart-Dock" :
                        command => "/usr/bin/killall Dock",
                        refreshonly => true;
                }
                file {
                    "/usr/local/bin/changebackground.sh" :
                        source => "puppet:///modules/vnc/changebackground.sh",
                        owner => "$users::root::username",
                        group => "$users::root::group",
                        mode => 0755,
                        notify => Exec["set-background-image"] ;
                }
            }
        }
        Ubuntu: {
            file {
                "/usr/share/glib-2.0/schemas/99_gsettings.gschema.override":
                    notify => Exec['update-gsettings'],
                    source => "puppet:///modules/vnc/gsettings.gschema.override";
            }
            exec {
                "update-gsettings":
                    command => "/usr/bin/glib-compile-schemas /usr/share/glib-2.0/schemas",
                        refreshonly => true;
            }
        }
        default: {
            fail("Don't know how to set up VNC appearance on $::operatingsystem")
        }
    }
}
