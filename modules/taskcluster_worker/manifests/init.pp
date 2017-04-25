class taskcluster_worker {
    include packages::mozilla::taskcluster_worker
    include ::users::root
    include ::users::builder
    include ::config

    $puppet_servers = $::config::puppet_servers
    file { '/etc/taskcluster-worker.yml':
        ensure => present,
        content => template('taskcluster_worker/taskcluster-worker.yml.erb'),
        mode => 0644,
        owner => $::users::root::username,
        group => $::users::root::group
    }

    case $::operatingsystem {
        Darwin: {
            file { '/Library/LaunchAgents/net.taskcluster.worker.plist':
                ensure => present,
                content => template('taskcluster_worker/taskcluster-worker.plist.erb'),
                mode => 0644,
                owner => $::users::root::username,
                group => $::users::root::group
            }
            service { "net.taskcluster.worker":
                require   => [
                    File["/Library/LaunchAgents/net.taskcluster.worker.plist"],
                ],
                enable    => true;
            }
        }

        Ubuntu: {
            file {
                ["${::users::builder::home}/.config",
                "${::users::builder::home}/.config/autostart"]:
                    ensure => directory,
                    owner  => $users::builder::username,
                    group  => $users::builder::group;
                "${::users::builder::home}/.config/autostart/gnome-terminal.desktop":
                    content => template("taskcluster_worker/gnome-terminal.desktop.erb"),
                    owner   => $users::builder::username,
                    group   => $users::builder::group;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
