class taskcluster_host_secrets {
    include packages::nodejs
    include packages::mozilla::taskcluster_host_secrets

    case $::operatingsystem {
        CentOS: {
            $taskcluster_access_token = secret('TC_HOST_SECRETS_ACCESS_TOKEN')
            if ($taskcluster_access_token == "")
                fail("missing TC_HOST_SECRETS_ACCESS_TOKEN")
            }
            $datacentre = regsubst($fqdn, '.*\.([a-z0-9]*)\.mozilla\.com$', '\1')
            $credentials_expiry = '4 days'
            $allowed_ips = '10.0.0.0/8'
            $service_port = 8080

            file { '/etc/host-secrets.conf':
                ensure => present,
                content => template('taskcluster_host_secrets/host-secrets.conf.erb'),
                mode => 0644,
                owner => root,
                group => wheel,
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
