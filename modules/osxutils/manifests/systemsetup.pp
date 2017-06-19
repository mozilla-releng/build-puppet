# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define osxutils::systemsetup ($option = $title,$setting = '') {

    $cmd = '/usr/sbin/systemsetup'

    if ($option != undef) and ($setting != undef) {
        exec {
            "osx_systemsetup -set${title} ${setting}" :
                command => "${cmd} -set${title} ${setting}",
                unless  =>
                    "${cmd} -get${title} | awk -F \": \" \'{print \$2}\' | grep -i ${setting}",
        }
    }
}
