class powermanagement::setup {
    include config
    include users::builder

    case $operatingsystem {
        Darwin : {
            osxutils::systemsetup {
                sleep :
                    setting => "Never" ;

                restartpowerfailure :
                    setting => "on" ;

                restartfreeze :
                    setting => "on" ;

                wakeonnetworkaccess :
                    setting => "on" ;

                allowpowerbuttontosleepcomputer :
                    setting => "off" ;
            }
            osxutils::defaults {
                "disable screensaver" :
                    domain => "com.apple.screensaver",
                    key => "idleTime",
                    value => 0,
                    user => $users::builder::username;
            }
        }
        CentOS : {
        # not yet implemented

        }
        default : {
            fail(" cannot install on $operatingsystem ")
        }
    }
}
