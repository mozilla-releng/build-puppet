# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define python27::user_pip_conf($homedir='', $group='') {
    include config

    $user                     = $title
    $homedir_                 = $homedir ? {
        ''      => "/home/${user}",
        default => $homedir,
    }
    $group_   = $group ? {
        ''      => $user,
        default => $group,
    }

    # for the template
    $user_python_repositories = $config::user_python_repositories
    case $::operatingsystem {
            windows: {
                file {
                    "${homedir_}/.pip":
                        ensure => directory;
                    "${homedir_}/.pip/pip.conf":
                        content => template('python27/user-pip-conf.erb');
                }
            }
            default: {
                file {
                    "${homedir_}/.pip":
                        ensure => directory,
                        owner  => $user,
                        group  => $group_;
                    "${homedir_}/.pip/pip.conf":
                        content => template('python27/user-pip-conf.erb'),
                        owner   => $user,
                        group   => $group_;
                    }
            }
    }
}
