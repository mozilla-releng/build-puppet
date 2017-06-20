# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::buildduty::setup($home, $username, $group) {
    anchor {
        'users::buildduty::setup::begin': ;
        'users::buildduty::setup::end': ;
    }

    ##
    # install a pip.conf for the buildduty user

    Anchor['users::buildduty::setup::begin'] ->
    python::user_pip_conf {
        $username:
            homedir => $home,
            group   => $group;
    } -> Anchor['users::buildduty::setup::end']

    ##
    # set up SSH configuration

    Anchor['users::buildduty::setup::begin'] ->
    ssh::userconfig {
        $username:
            home                          => $home,
            group                         => $group,
            authorized_keys               => $::config::admin_users,
            authorized_keys_allows_extras => true,
            config                        => template('users/buildduty-ssh-config.erb');
    } -> Anchor['users::buildduty::setup::end']

    ##
    # Manage some configuration files
    file {
        "${home}/.gitconfig":
            mode   => '0644',
            owner  => $username,
            group  => $group,
            source => 'puppet:///modules/users/gitconfig';
        "${home}/.bashrc":
            mode    => '0644',
            owner   => $username,
            group   => $group,
            content => template("${module_name}/buildduty-bashrc.erb");
        "${home}/.vimrc":
            mode   => '0644',
            owner  => $username,
            group  => $group,
            source => 'puppet:///modules/users/vimrc';
        "${home}/.screenrc":
            mode   => '0644',
            owner  => $username,
            group  => $group,
            source => 'puppet:///modules/users/screenrc';
    }
}
