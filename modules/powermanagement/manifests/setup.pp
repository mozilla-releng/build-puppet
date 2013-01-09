# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
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
