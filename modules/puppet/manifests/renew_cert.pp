# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppet::renew_cert {
    include puppet
    include config
    include stdlib
    include dirs::usr::local::bin

    # puppet::renew_cert only supports posix
    case $::operatingsystem {
        'CentOS', 'Ubuntu', 'Darwin': {}
        default: { fail("pupppet::renew_cert support missing for ${::operatingsystem}") }
    }

    $enddate = $::puppet_agent_cert_enddate
    $issuer  = $::puppet_agent_cert_issuer
    $second_in_30_days = 60 * 60 * 24 * 30
    $thirty_days_before_exp = $enddate - $second_in_30_days

    $all_puppet_cas = $::config::valid_puppet_cas
    $nearby_puppet_cas = $::config::nearby_puppet_cas

    # If this hosts main puppet server is valid then use it
    # otherwise pick a nearby (same DC) puppet CA
    # lastly, pick any valid CA
    if $::config::puppet_server in $::config::valid_puppet_cas {
        $ca_server = $::config::puppet_server
    } elsif size($nearby_puppet_cas) != 0 {
        $servers = fqdn_rotate($nearby_puppet_cas)
        $ca_server = $servers[0]
    } else {
        $servers = fqdn_rotate($all_puppet_cas)
        $ca_server = $servers[0]
    }

    # If the assigned CA doesn't match the current cert CA
    # or if current cert expires in less than 30 days
    # then drop deploy password on disk
    if $ca_server != $issuer {
        $ensure_deploypass = 'file'
    } elsif $thirty_days_before_exp <= time() {
        $ensure_deploypass = 'file'
    } else {
        $ensure_deploypass = 'absent'
    }

    file { '/var/lib/puppet/deploypass':
        ensure    => $ensure_deploypass,
        mode      => filemode('600'),
        content   => secret('deploy_password'),
        show_diff => false,
        require   => File['/usr/local/bin/renew_cert.sh'];
    }

    file { '/usr/local/bin/renew_cert.sh':
        source => 'puppet:///modules/puppet/renew_cert.sh',
        mode   => filemode(0755);
    }

    $minute1 = fqdn_rand(15)
    $minute2 = $minute1+15
    $minute3 = $minute2+15
    $minute4 = $minute3+15

    case $::operatingsystem {
        CentOS,Ubuntu: {
            file {
                '/etc/cron.d/renew_puppet_cert_check':
                    content => template('puppet/renew_puppet_cert_check.cron.erb'),
                    require => File['/usr/local/bin/renew_cert.sh'];
            }
        }
        Darwin: {
            $cron_cmd = ". /usr/local/bin/proxy_reset_env.sh && PUPPET_SERVER=${ca_server} /usr/local/bin/renew_cert.sh > /dev/null 2>&1"
            cron {
                'renew_puppet_cert_check':
                    command => $cron_cmd,
                    minute  => [ $minute1, $minute2, $minute3, $minute4 ];
            }
        }
        default: {
            fail("pupppet::renew_cert support missing for ${::operatingsystem}")
        }
    }
}
