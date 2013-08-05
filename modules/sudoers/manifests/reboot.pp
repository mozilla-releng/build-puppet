# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class sudoers::reboot {
    include sudoers
    include sudoers::settings
    include config
    include users::builder

    file {
        "/etc/sudoers.d/reboot" :
            mode => $sudoers::settings::mode,
            owner => $sudoers::settings::owner,
            group => $sudoers::settings::group,
            ensure => file,
            content => "${users::builder::username} ALL=NOPASSWD: $sudoers::settings::rebootpath\n" ;
    }
}
