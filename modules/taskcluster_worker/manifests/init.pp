# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class taskcluster_worker {
    include packages::mozilla::taskcluster_worker
    include ::dirs::usr::local::bin
    include ::users::root
    include ::users::builder
    include ::config

    $taskcluster_worker_group = regsubst($::fqdn, '.*\.releng\.(.+)\.mozilla\..*', '\1')
    $tc_host_secrets_servers = $::config::tc_host_secrets_servers
    file { '/etc/taskcluster-worker.yml':
        ensure  => present,
        content => template('taskcluster_worker/taskcluster-worker.yml.erb'),
        mode    => '0644',
        owner   => $::users::root::username,
        group   => $::users::root::group
    }

    case $::operatingsystem {
        Darwin: {
            file { '/Library/LaunchAgents/net.taskcluster.worker.plist':
                ensure  => present,
                content => template('taskcluster_worker/taskcluster-worker.plist.erb'),
                mode    => '0644',
                owner   => $::users::root::username,
                group   => $::users::root::group
            }
            service { 'net.taskcluster.worker':
                require => [
                    File['/Library/LaunchAgents/net.taskcluster.worker.plist'],
                ],
                enable  => true;
            }
        }

        Ubuntu: {
            file {
                ["${::users::builder::home}/.config",
                "${::users::builder::home}/.config/autostart"]:
                    ensure => directory,
                    owner  => $users::builder::username,
                    group  => $users::builder::group;
                '/usr/local/bin/run-tc-worker.sh':
                    source => 'puppet:///modules/taskcluster_worker/run-tc-worker.sh',
                    mode   => '0755',
                    owner  => $users::root::username,
                    group  => $users::root::group;
                "${::users::builder::home}/.config/autostart/gnome-terminal.desktop":
                    content => template('taskcluster_worker/gnome-terminal.desktop.erb'),
                    owner   => $users::builder::username,
                    group   => $users::builder::group;
            }
        }

        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
