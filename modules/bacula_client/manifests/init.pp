# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class bacula_client($cert, $key) {
    # $cert and $key are the pem-formatted TLS certificate and key for this host
    include ::config

    case $operatingsystem {
        CentOS: {
            include packages::bacula_enterprise_client

            $owner = 'root'
            $group = 'bacula'

            $bacula_director = $::config::bacula_director
            $bacula_fd_port = $::config::bacula_fd_port

            $bacula_director_password = secret("bacula_director_password")

            file {
                '/opt/bacula/etc/bacula-fd.conf':
                    ensure     => file,
                    owner      => $owner,
                    group      => $group,
                    mode       => '0640',
                    notify     => Service['bacula-fd'],
                    require    => Class['packages::bacula_enterprise_client'],
                    content    => template('bacula_client/bacula-fd.conf.erb');
                '/opt/bacula/ssl':
                    ensure     => directory,
                    owner      => $owner,
                    group      => $group,
                    mode       => '0640',
                    require    => Class['packages::bacula_enterprise_client'];
                '/opt/bacula/ssl/cacert.pem':
                    ensure     => file,
                    owner      => $owner,
                    group      => $group,
                    mode       => '0640',
                    notify     => Service['bacula-fd'],
                    require    => File['/opt/bacula/ssl'],
                    content    => $::config::bacula_cacert;
                "/opt/bacula/ssl/${fqdn}-cert.pem":
                    ensure     => file,
                    owner      => $owner,
                    group      => $group,
                    mode       => '0640',
                    notify     => Service['bacula-fd'],
                    require    => File['/opt/bacula/ssl'],
                    content    => $cert;
                "/opt/bacula/ssl/${fqdn}-key.pem":
                    ensure     => file,
                    owner      => $owner,
                    group      => $group,
                    mode       => '0640',
                    notify     => Service['bacula-fd'],
                    require    => File['/opt/bacula/ssl'],
                    content    => $key;
            }

            service {
                'bacula-fd':
                    ensure => running,
                    enable => true,
                    require => Class['packages::bacula_enterprise_client'];
            }
        }
        default: {
            fail("Bacula not supported on $operatingsystem")
        }
    }
}
