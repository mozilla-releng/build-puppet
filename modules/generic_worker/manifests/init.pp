# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class generic_worker {
    include packages::mozilla::generic_worker
    include ::users::root
    include ::users::builder
    include ::config
    include generic_worker::control_bug

    $taskcluster_host = 'taskcluster'
    $livelog_secret = hiera('livelog_secret')
    $livelog_certificate = "${::users::builder::home}/livelog.crt"
    $livelog_key = "${::users::builder::home}/livelog.key"
    $worker_group = regsubst($::fqdn, '.*\.releng\.(.+)\.mozilla\..*', '\1')
    $task_dir = "${::users::builder::home}/tasks"
    $caches_dir = "${::users::builder::home}/cache"
    $downloads_dir = "${::users::builder::home}/downloads"
    $signing_key = "${::users::builder::home}/generic-worker.openpgp.key"

    $quarantine_client_id = secret('quarantine_client_id')
    $quarantine_access_token = hiera('quarantine_access_token')

    case $::operatingsystem {
        Darwin: {
            $macos_version = regsubst($::macosx_productversion_major, '\.', '')
            if ($environment == 'staging') {
                $worker_type = "gecko-t-osx-${macos_version}-beta"
                $taskcluster_client_id = secret('osx_staging_client')
                $taskcluster_access_token = hiera('osx_staging_client_token')
            }
            else {
                $worker_type = "gecko-t-osx-${macos_version}"
                $taskcluster_client_id = secret('generic_worker_macosx_client_id')
                $taskcluster_access_token = hiera('generic_worker_macosx_access_token')
            }

            file { '/Library/LaunchAgents/net.generic.worker.plist':
                ensure  => present,
                content => template('generic_worker/generic-worker.plist.erb'),
                mode    => '0644',
                owner   => $users::root::username,
                group   => $users::root::group;
            }
            file { '/usr/local/bin/run-generic-worker.sh':
                ensure  => present,
                content => template('generic_worker/run-generic-worker.sh.erb'),
                mode    => '0755',
                owner   => $users::root::username,
                group   => $users::root::group;
            }
            file { '/etc/generic-worker.config':
                ensure  => present,
                content => template('generic_worker/generic-worker.config.erb'),
                mode    => '0644',
                owner   => $users::root::username,
                group   => $users::root::group;
            }
            service { 'net.generic.worker':
                require => [
                    File['/Library/LaunchAgents/net.generic.worker.plist'],
                ],
                enable  => true;
            }
            exec { 'create gpg key':
                path    => ['/bin', '/sbin', '/usr/local/bin'],
                user    => $users::builder::username,
                command => 'generic-worker new-openpgp-keypair --file /Users/cltbld/generic-worker.openpgp.key',
                unless  => 'test -f /Users/cltbld/generic-worker.openpgp.key'
            }
            host {"${taskcluster_host}":
                ip => '127.0.0.1'
            }

            httpd::config {
                'proxy.conf':
                    content => template('generic_worker/proxy-httpd.conf.erb');
            }
        }
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04: {
                    if ($environment == 'staging') {
                        $worker_type = "gecko-t-osx-linux-talos-beta"
                        $taskcluster_client_id = secret('generic_worker_linux_staging_client_id')
                        $taskcluster_access_token = hiera('generic_worker_linux_staging_access_token')
                    }
                    else {
                        $worker_type = "gecko-t-osx-linux-talos"
                        $taskcluster_client_id = secret('generic_worker_linux_client_id')
                        $taskcluster_access_token = hiera('generic_worker_linux_access_token')
                    }
                    file {
                        ["${::users::builder::home}/.config",
                        "${::users::builder::home}/.config/autostart"]:
                            ensure => directory,
                            owner  => $users::builder::username,
                            group  => $users::builder::group;
                        "${::users::builder::home}/.config/autostart/gnome-terminal.desktop":
                            content => template('generic_worker/gnome-terminal.desktop.erb'),
                            owner   => $users::builder::username,
                            group   => $users::builder::group;
                    }
                    file { '/usr/local/bin/run-generic-worker.sh':
                        ensure  => present,
                        content => template('generic_worker/run-generic-worker.sh.erb'),
                        mode    => '0755',
                        owner   => $users::root::username,
                        group   => $users::root::group;
                    }
                    file { '/etc/generic-worker.config':
                        ensure  => present,
                        content => template('generic_worker/generic-worker.config.erb'),
                        mode    => '0644',
                        owner   => $users::root::username,
                        group   => $users::root::group;
                    }
                    exec { 'create gpg key':
                        path    => ['/bin', '/sbin', '/usr/local/bin', '/usr/bin'],
                        user    => $users::builder::username,
                        command => "generic-worker new-openpgp-keypair --file ${::users::builder::home}/generic-worker.openpgp.key",
                        unless  => "test -f ${::users::builder::home}/generic-worker.openpgp.key"
                    }

                    host {"${taskcluster_host}":
                        ip => '127.0.0.1'
                    }
                    httpd::config {
                        'proxy.conf':
                            content => template('generic_worker/proxy-httpd.conf.erb');
                    }
                }
                default: {
                    fail("cannot install on ${::operatingsystemrelease}")
                }
            }
        }
        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}
