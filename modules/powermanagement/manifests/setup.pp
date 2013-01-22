class powermanagement::setup {
    include config
    include users::builder

    case $::operatingsystem {
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
        }
        CentOS, Ubuntu : {
        # not yet implemented
        }
        default : {
            fail(" cannot install on $::operatingsystem ")
        }
    }
}
