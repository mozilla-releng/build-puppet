# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define collectd::util::config_gen ($arg_array) {
    include collectd::settings

    file {
        "${collectd::settings::plugindir}/${name}.conf":
            ensure  => present,
            mode    => '0644',
            notify  => Service[$collectd::settings::servicename],
            content => template('collectd/collectd.d/plugin_config.erb');
    }
}

