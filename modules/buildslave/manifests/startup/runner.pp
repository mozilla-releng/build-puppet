# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildslave::startup::runner {
    case $::operatingsystem {
        'CentOS': {
            file {
                '/etc/init.d/buildbot':
                    ensure => absent,
                    notify => Exec['bb-service-delete'];
            }
            exec {
                'bb-service-delete':
                    command     => "/bin/find /etc/rc.d -type l -name '*buildbot' | /usr/bin/xargs /bin/rm",
                    refreshonly => true;
            }
        }
        'Ubuntu': {
            file {
                "${::users::builder::home}/.config/autostart/gnome-terminal.desktop":
                    ensure => absent;
            }
        }
        'Darwin': {
            include runner::tasks::darwin_clean_buildbot
            # TODO: Stop ensuring that buildslave.plist is absent after
            # some reasonable amount of time passes (1 month post deployment).
            # This is strictly a cleanup measure for moving off of the old
            # launchd startup.
            file {
                '/Library/LaunchAgents/com.mozilla.buildslave.plist':
                    ensure => absent;
            }
        }
    }
    include runner::tasks::buildbot
    include runner::tasks::halt
    if ($::operatingsystem != Windows) {
        include runner::tasks::cleanslate_task
        include runner::tasks::post_flight
    }
}
