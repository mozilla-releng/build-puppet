# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::root::setup($home, $username, $group) {
    anchor {
        'users::root::setup::begin': ;
        'users::root::setup::end': ;
    }
    include ::config

    ##
    # install a pip.conf for the root user

    Anchor['users::root::setup::begin'] ->
    python::user_pip_conf {
        $username:
            homedir => $home,
            group   => $group;
    } -> Anchor['users::root::setup::end']

    ##
    # set up SSH configuration

    if $only_user_ssh {
        Anchor['users::root::setup::begin'] ->
        ssh::userconfig {
            $username:
                home                          => $home,
                group                         => $group,
                cleartext_password            => secret('root_pw_cleartext'),
                authorized_keys               => [],  # nobody is authorized
                authorized_keys_allows_extras => false,
        } -> Anchor['users::root::setup::end']
    }
    else {
        Anchor['users::root::setup::begin'] ->
        ssh::userconfig {
            $username:
                home                          => $home,
                group                         => $group,
                cleartext_password            => secret('root_pw_cleartext'),
                authorized_keys               => $::config::admin_users,
                authorized_keys_allows_extras => true,
        } -> Anchor['users::root::setup::end']
    }

    ##
    # Manage some configuration files
    if ($::operatingsystem == Ubuntu) {
        # patch out /root/.bashrc to not reset $PS1; $PS1 is set in users::global
        file {
            "${home}/.bashrc":
                owner  => $username,
                group  => $group,
                source => 'puppet:///modules/users/ubuntu-root-bashrc';
        }
    }
}
