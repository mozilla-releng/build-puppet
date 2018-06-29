# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class users::roller::setup($home, $username, $group) {
    anchor {
        'users::roller::setup::begin': ;
        'users::roller::setup::end': ;
    }

    Anchor['users::roller::setup::begin'] ->
    ssh::userconfig {
        $username:
            home                          => $home,
            group                         => $group,
            authorized_keys               => 'roller_ssh_pub_key',  # key into config::extra_user_ssh_keys
            authorized_keys_allows_extras => false
    } -> Anchor['users::roller::setup::end']

    case $::operatingsystem {
        # Roller first tries ssh to reboot
        Ubuntu, Darwin: {
            include sudoers
            include sudoers::settings
            include users::roller

            sudoers::custom {
                'roller-reboot':
                    user    => $users::roller::username,
                    runas   => 'root',
                    command => $sudoers::settings::rebootpath;
            }
        }
    }

    $mac_netboot_ips = $::config::mac_netboot_ips

    file {
        "${home}/.ssh/allowed_commands.sh":
            mode    => filemode(0700),
            owner   => $username,
            group   => $group,
            content => template('users/roller-allowed_commands.sh.erb');
    }
}
