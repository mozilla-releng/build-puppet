# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class collectd {
    include collectd::settings

    # do not configure unless graphite server is defined
    if $collectd::settings::collectd_enabled == true {
        include packages::collectd
        include collectd::profiles

        file {
            "${collectd::settings::configdir}/collectd.conf":
                ensure  => present,
                content => template('collectd/collectd.conf.erb'),
                notify  => Service[$collectd::settings::servicename],
                require => Class['packages::collectd'];

            $collectd::settings::plugindir:
                ensure  => directory,
                recurse => true,
                purge   => true,
                force   => true,
                mode    => '0644',
                notify  => Service[$collectd::settings::servicename],
                require => Class['packages::collectd'];
        }

        if $collectd::settings::servicescript {
            file {
              "${collectd::settings::servicepath}/${collectd::settings::servicescript}":
                ensure  => present,
                source  => "puppet:///modules/collectd/${collectd::settings::servicescript}",
                notify  => Service[$collectd::settings::servicename],
                require => Class['packages::collectd'];
            }
        }

        service {
            $collectd::settings::servicename:
                ensure     => running,
                enable     => true,
                hasstatus  => true,
                hasrestart => true,
                require    => Class['packages::collectd'];
        }
    }
}

