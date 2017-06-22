# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class sudoers::settings {
    include ::shared
    include users::root
    $group = $users::root::group
    $owner = $users::root::username
    $mode  = '0440'
    case $::operatingsystem {
        CentOS: {
            $rebootpath = '/usr/bin/reboot'
        }
        Darwin, Ubuntu: {
            $rebootpath = '/sbin/reboot'
        }
    }
}
