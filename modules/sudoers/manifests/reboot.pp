# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class sudoers::reboot {
    include sudoers
    include sudoers::settings
    include config
    include users::builder

    sudoers::custom {
        'builder-reboot':
            user    => $users::builder::username,
            runas   => 'root',
            command => $sudoers::settings::rebootpath;
    }
}
