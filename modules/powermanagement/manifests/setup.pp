class powermanagement::setup {
    include config case $operatingsystem {
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
                    user => $config::builder_username
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
