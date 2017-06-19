# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define osxutils::defaults ($domain = undef,
    $key = undef,
    $value = undef,
    $user = 'root') {
    $defaults_cmd = '/usr/bin/defaults'
    if ($domain != undef) and ($key != undef) and ($value != undef) {
        exec {
            "osx_defaults write ${domain} ${key}=>${value}" :
                command =>
                "${defaults_cmd} write ${domain} ${key} ${value}",
                unless  =>
                "/bin/test x`${defaults_cmd} read ${domain} ${key}` = x'${value}'",
                user    => $user,
        }
    }
    else {
        warning('Cannot ensure present without domain, key, and value attributes')
    }
}
