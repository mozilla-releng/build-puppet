# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildslave::startup::runner {
    case $::operatingsystem {
        'CentOS': {
            file {
                "/etc/init.d/buildbot":
                    ensure => absent,
                    notify => Exec['bb-service-delete'];
            }
            exec {
                'bb-service-delete':
                    command => "/bin/find /etc/rc.d -type l -name '*buildbot' | /usr/bin/xargs /bin/rm",
                    refreshonly => true;
            }
        }
        'Ubuntu': {
            file {
                "${::users::builder::home}/.config/autostart/gnome-terminal.desktop":
                    ensure => absent;
            }
        }
    }
    include runner::tasks::buildbot
}
