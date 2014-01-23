# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class casper::fileserver {
    include casper::settings

    $fs_accounts = $casper::settings::fs_accounts

    # We will only support casper under OSX 10.8 and 10.9
    
    case $::operatingsystem {
        Darwin: {
            case $::macosx_productversion_major {
                '10.8','10.9': {
                    create_resources(casper::casperuser, $fs_accounts)
                }

                default: { fail ("This OSX version is not supported") }
            }
        }

        default: { fail ("This OS does not support casper") }
    }
}
