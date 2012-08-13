class vnc::appearance {

include dirs::usr::local::bin
include users::root


if (!$puppetizing) {
        exec {
                "set-background-image" :
                        command => "/bin/bash /usr/local/bin/changebackground.sh",
                        unless => "/usr/bin/defaults read com.apple.desktop Background | egrep 'Solid Aqua Blue.png'",
                        notify => Exec["restart-Dock"] ;
                "restart-Dock" :
                        command => "/usr/bin/killall Dock";
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