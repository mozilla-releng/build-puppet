# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class powermanagement::setup {
    include config

    case $::operatingsystem {
        Darwin : {
            osxutils::systemsetup {
                sleep :
                    setting => 'Never' ;

                restartpowerfailure :
                    setting => 'on' ;

                wakeonnetworkaccess :
                    setting => 'on' ;

                allowpowerbuttontosleepcomputer :
                    setting => 'off' ;
            }
            case $::macosx_productversion_major {
                # 10.6 doesn't support this option
                '10.6': {}
                default: {
                    osxutils::systemsetup {
                        'restartfreeze':
                            setting => 'on';
                    }
                }
            }
        }
        CentOS, Ubuntu : {
        # not yet implemented
        }
        Windows: {
            # TODO-WIN: this is currently managed through GPO.
        }
        default : {
            fail(" cannot install on ${::operatingsystem}")
        }
    }
}
