class taskcluster_worker {
    include packages::mozilla::taskcluster_worker

    case $::operatingsystem {
        Darwin: {
            $macos_version = regsubst($::macosx_productversion_major, '\.', '-')
            $taskcluster_client_id = secret('taskcluster_worker_client_id')
            $taskcluster_access_token = hiera('taskcluster_worker_access_token')

            file { '/Library/LaunchAgents/net.taskcluster.worker.plist':
                ensure => present,
                content => template('taskcluster_worker/taskcluster-worker.plist.erb'),
                mode => 0644,
                owner => root,
                group => wheel,
            }
            file { '/etc/taskcluster-worker.yml':
                ensure => present,
                content => template('taskcluster_worker/taskcluster-worker.yml.erb'),
                mode => 0644,
                owner => root,
                group => wheel,
            }
            service { "net.taskcluster.worker":
                require   => [
                    File["/Library/LaunchAgents/net.taskcluster.worker.plist"],
                ],
                enable    => true;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
