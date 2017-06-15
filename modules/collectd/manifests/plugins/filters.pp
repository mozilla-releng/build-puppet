# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::filters ( $write_chains ) {
    include collectd
    include collectd::settings


    validate_hash($write_chains)

    file {
        "${collectd::settings::plugindir}/filters.conf":
            ensure  => present,
            mode    => '0644',
            notify  => Service[$collectd::settings::servicename],
            content => template('collectd/collectd.d/filters.conf.erb');
    }

}
