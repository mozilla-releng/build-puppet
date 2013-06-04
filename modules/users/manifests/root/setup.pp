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
            group => $group;
    } -> Anchor['users::root::setup::end']

    ##
    # set up SSH configuration

    Anchor['users::root::setup::begin'] ->
    ssh::userconfig {
        $username:
            home => $home,
            group => $group,
            authorized_keys => [
                $::config::global_authorized_keys,
                # get the node-scoped value, if any
                $extra_root_keys ? {
                    undef => [ ],
                    default => $extra_root_keys
                }];
    } -> Anchor['users::root::setup::end']

    ##
    # Manage some configuration files

    file {
        "$home/.hgrc":
            mode => 0644,
            owner => $username,
            group => $group,
            source => "puppet:///modules/users/hgrc";
    }

    if ($::operatingsystem == Ubuntu) {
        # patch out /root/.bashrc to not reset $PS1; $PS1 is set in users::global
        file {
            "$home/.bashrc":
                mode => 0644,
                owner => $username,
                group => $group,
                source => "puppet:///modules/users/ubuntu-root-bashrc";
        }
    }
}
