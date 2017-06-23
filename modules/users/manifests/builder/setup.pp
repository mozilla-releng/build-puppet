# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::builder::setup($home, $username, $group) {
    anchor {
        'users::builder::setup::begin': ;
        'users::builder::setup::end': ;
    }

    ##
    # install a pip.conf for the builder user

    Anchor['users::builder::setup::begin'] ->
    python::user_pip_conf {
        $username:
            homedir => $home,
            group   => $group;
    } -> Anchor['users::builder::setup::end']

    ##
    # set up SSH configuration

    Anchor['users::builder::setup::begin'] ->
    ssh::userconfig {
        $username:
            home                          => $home,
            group                         => $group,
            authorized_keys               => $::config::admin_users,
            authorized_keys_allows_extras => true,
            cleartext_password            => secret('builder_pw_cleartext'),
            config                        => template('users/builder-ssh-config.erb');
    } -> Anchor['users::builder::setup::end']

    ##
    # Manage some configuration files
    case $::operatingsystem {
        Windows: {
            case $::env_os_version {
                2008: {
                    mercurial::hgrc {
                        "${home}/.hgrc":
                            owner => $username,
                            group => $group;
                    }
                }
                # Windows tester mecurial support will be added in the future
                default: {
                }
            }
        }
        default: {
            mercurial::hgrc {
                "${home}/.hgrc":
                    owner => $username,
                    group => $group;
            }
        }
    }

    file {
        "${home}/.gitconfig":
            mode   => filemode(0644),
            owner  => $username,
            group  => $group,
            source => 'puppet:///modules/users/gitconfig';
        "${home}/.bashrc":
            mode    => filemode(0644),
            owner   => $username,
            group   => $group,
            content => template("${module_name}/builder-bashrc.erb");
        "${home}/.vimrc":
            mode   => filemode(0644),
            owner  => $username,
            group  => $group,
            source => 'puppet:///modules/users/vimrc';
        "${home}/.screenrc":
            mode   => filemode(0644),
            owner  => $username,
            group  => $group,
            source => 'puppet:///modules/users/screenrc';
    }
}
