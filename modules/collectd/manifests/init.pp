# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class collectd {
    include collectd::settings

    # do not configure unless graphite server is defined
    if $collectd::settings::graphite_cluster_fqdn and $collectd::settings::graphite_cluster_fqdn != "" {
        include packages::collectd

        file {
            "${collectd::settings::configdir}/collectd.conf":
                ensure  => present,
                content => template('collectd/collectd.conf.erb'),
                notify  => Service['collectd'],
                require => Class['packages::collectd'];

            $collectd::settings::plugindir:
                ensure  => directory,
                recurse => true,
                purge   => true,
                force   => true,
                mode    => 0644,
                notify  => Service['collectd'],
                require => Class['packages::collectd'];

            "${collectd::settings::plugindir}/common.conf":
                ensure  => present,
                mode    => '0755',
                notify  => Service['collectd'],
                content => template('collectd/collectd.d/common.conf.erb'),
                require => Class['packages::collectd'];
        }

        service {
            'collectd':
                ensure     => running,
                enable     => true,
                hasstatus  => true,
                hasrestart => true,
        }
    }
}

