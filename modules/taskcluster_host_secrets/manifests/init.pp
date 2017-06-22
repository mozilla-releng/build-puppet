# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class taskcluster_host_secrets {
    include packages::nodejs
    include packages::mozilla::taskcluster_host_secrets

    case $::operatingsystem {
        CentOS: {
            $taskcluster_access_token = secret('TC_HOST_SECRETS_ACCESS_TOKEN')
            if ($taskcluster_access_token == '') {
                fail('missing TC_HOST_SECRETS_ACCESS_TOKEN')
            }
            $credentials_expiry = '4 days'
            $allowed_ips        = '::ffff:10.0.0.0/8 10.0.0.0/8'
            $service_port       = 8020

            file { '/etc/host-secrets.conf':
                ensure  => present,
                content => template('taskcluster_host_secrets/host-secrets.conf.erb'),
                mode    => '0644',
                owner   => root,
                group   => wheel,
                notify  => Service['host-secrets'],
            }

            file { '/usr/bin/host-secrets':
                ensure => link,
                target => '/opt/taskcluster-host-secrets/bin/start.sh'
            }

            # /etc/init.d/host-secrets is installed by the rpm package included above. source at:
            # https://github.com/taskcluster/taskcluster-host-secrets/blob/packaging/init.d.in

            service { 'host-secrets':
                ensure => running,
                enable => true
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
