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
            authorized_keys               => 'roller_ssh_pub_key',
            authorized_keys_allows_extras => false,
            config                        => template('users/roller-ssh-config.erb');
    } -> Anchor['users::roller::setup::end']

    case $::operatingsystem {
        # Roller needs ssh for reboot on macs only
        Darwin: {
            include sudoers
            include sudoers::settings
            include users::roller

            sudoers::custom {
                'roller-reboot':
                    user    => $users::roller::username,
                    runas   => 'root',
                    command => "$sudoers::settings::rebootpath, /usr/sbin/bless";
            }
        }
    }

    $mac_netboot_ips = [ '10.26.52.17',  # install.build.releng.scl3
                         '10.26.56.110', # install.test.releng.scl3
                         '10.49.56.16',  # install.test.releng.mdc1
                         '10.51.56.16' ] # install.test.releng.mdc2
    file {
        "${home}/.ssh/allowed_commands.sh":
            mode    => filemode(0700),
            owner   => $username,
            group   => $group,
            content => template('users/roller-allowed_commands.sh.erb');
    }
}
