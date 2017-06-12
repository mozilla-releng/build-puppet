# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class auditd($host_type) {
    include packages::auditd
    include packages::audisp_cef
    $packages = [
        Class['packages::auditd'],
        Class['packages::audisp_cef'],
    ]

    # filter legitimate host types; these are used by the
    # rules template to decide how to configure the host
    case $host_type {
        'slave': { }
        'server': { }
        default: {
            fail("Invalid auditd host_type ${host_type}")
        }
    }

    case $::operatingsystem {
        CentOS: {
            # rsyslog's upstream default config logs all the auditd stuff
            # to 'messages', which is super-noisy.  The puppet module filters
            # that by default (bug 1100395).
            include rsyslog

            service {
                'auditd':
                    ensure    => running,
                    enable    => true,
                    subscribe => $packages,
                    hasstatus => true;
            }

            file {
                '/etc/audit/auditd.conf':
                    ensure  => file,
                    require => $packages,
                    notify  => Service['auditd'],
                    owner   => 'root',
                    group   => 'root',
                    mode    => '0600',
                    source  => 'puppet:///modules/auditd/auditd.conf';

                '/etc/audisp/audispd.conf':
                    ensure  => file,
                    require => $packages,
                    notify  => Service['auditd'],
                    owner   => 'root',
                    group   => 'root',
                    mode    => '0600',
                    source  => 'puppet:///modules/auditd/audispd.conf';

                '/etc/audisp/plugins.d/syslog.conf':
                    ensure  => file,
                    require => $packages,
                    notify  => Service['auditd'],
                    owner   => root,
                    group   => root,
                    mode    => '0600',
                    source  => 'puppet:///modules/auditd/syslog.conf';

                '/var/log/audit':
                    ensure => directory,
                    owner  => root,
                    group  => root,
                    mode   => '0700';

                '/etc/audit/audit.rules':
                    ensure  => file,
                    require => $packages,
                    notify  => Service['auditd'],
                    owner   => 'root',
                    group   => 'root',
                    mode    => '0600',
                    # this can  use $host_type to decide which rules to apply
                    content => template('auditd/audit.rules.erb');
            }
        }
    }
}
