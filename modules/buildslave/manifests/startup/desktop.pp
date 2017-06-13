# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildslave::startup::desktop {
    include users::builder
    include packages::mozilla::python27

    case $::operatingsystem {
        Ubuntu: {
            file {
                ["${::users::builder::home}/.config",
                "${::users::builder::home}/.config/autostart"]:
                    ensure => directory,
                    owner  => $users::builder::username,
                    group  => $users::builder::group;
                "${::users::builder::home}/.config/autostart/gnome-terminal.desktop":
                    require => File['/usr/local/bin/runslave.py'],
                    content => template('buildslave/gnome-terminal.desktop.erb'),
                    owner   => $users::builder::username,
                    group   => $users::builder::group;
            }
        }
    }
}