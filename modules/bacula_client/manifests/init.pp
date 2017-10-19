# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class bacula_client($cert, $key) {
    # $cert and $key are the pem-formatted TLS certificate and key for this host
    include ::config
    include packages::bacula_enterprise_client
    include bacula_client::settings

    if $::operatingsystem == 'Darwin' {
        include packages::openssl_non_xcode
    }

    case $::operatingsystem {
        CentOS, Darwin: {

            $bacula_director = $::config::bacula_director
            $bacula_fd_port = $::config::bacula_fd_port

            $bacula_pki_enabled = $::config::bacula_pki_enabled

            $bacula_director_password = secret('bacula_director_password')

            file {
                $bacula_client::settings::confpath:
                    ensure  => directory,
                    owner   => $bacula_client::settings::owner,
                    group   => $bacula_client::settings::group,
                    mode    => '0755',
                    require => Class['packages::bacula_enterprise_client'];
                "${bacula_client::settings::confpath}/bacula-fd.conf":
                    ensure    => file,
                    owner     => $bacula_client::settings::owner,
                    group     => $bacula_client::settings::group,
                    mode      => '0640',
                    notify    => Service[$bacula_client::settings::servicename],
                    show_diff => false,
                    require   => Class['packages::bacula_enterprise_client'],
                    content   => template('bacula_client/bacula-fd.conf.erb');
                '/opt/bacula/plugins':
                    ensure  => directory,
                    owner   => $bacula_client::settings::owner,
                    group   => $bacula_client::settings::group,
                    mode    => '0640',
                    require => Class['packages::bacula_enterprise_client'];
                '/opt/bacula/ssl':
                    ensure  => directory,
                    owner   => $bacula_client::settings::owner,
                    group   => $bacula_client::settings::group,
                    mode    => '0640',
                    purge   => true,
                    recurse => true,
                    require => Class['packages::bacula_enterprise_client'];
                '/opt/bacula/ssl/cacert.pem':
                    ensure  => file,
                    owner   => $bacula_client::settings::owner,
                    group   => $bacula_client::settings::group,
                    mode    => '0640',
                    notify  => Service[$bacula_client::settings::servicename],
                    require => File['/opt/bacula/ssl'],
                    content => $::config::bacula_cacert;
                "/opt/bacula/ssl/${::fqdn}-crt.pem":
                    ensure  => file,
                    owner   => $bacula_client::settings::owner,
                    group   => $bacula_client::settings::group,
                    mode    => '0640',
                    notify  => Service[$bacula_client::settings::servicename],
                    require => File['/opt/bacula/ssl'],
                    content => $cert;
                "/opt/bacula/ssl/${::fqdn}-key.pem":
                    ensure    => file,
                    owner     => $bacula_client::settings::owner,
                    group     => $bacula_client::settings::group,
                    mode      => '0600',
                    notify    => Service[$bacula_client::settings::servicename],
                    show_diff => false,
                    require   => File['/opt/bacula/ssl'],
                    content   => $key;
                "/opt/bacula/ssl/${::fqdn}-client.pem":
                    ensure    => file,
                    owner     => $bacula_client::settings::owner,
                    group     => $bacula_client::settings::group,
                    mode      => '0600',
                    notify    => Service[$bacula_client::settings::servicename],
                    show_diff => false,
                    require   => File['/opt/bacula/ssl'],
                    content   => "${key}${cert}";
            }

            service {
                $bacula_client::settings::servicename:
                    ensure  => running,
                    enable  => true,
                    require => Class['packages::bacula_enterprise_client'];
            }
        }
        default: {
            fail("Bacula not supported on ${::operatingsystem}")
        }
    }
}
