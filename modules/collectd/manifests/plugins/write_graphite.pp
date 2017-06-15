# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::write_graphite ( $nodes ) {
    include collectd
    include collectd::settings


    $plugin_name = 'write_graphite'

    validate_hash($nodes)

    file {
        "${collectd::settings::plugindir}/write_graphite.conf":
            ensure  => present,
            mode    => '0644',
            notify  => Service[$collectd::settings::servicename],
            content => template('collectd/collectd.d/write_graphite.conf.erb');
    }

}
