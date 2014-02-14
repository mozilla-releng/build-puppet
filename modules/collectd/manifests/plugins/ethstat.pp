# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::ethstat {
    include collectd
    include collectd::settings

    # https://collectd.org/wiki/index.php/Plugin:Ethstat

    $plugin_name = 'ethstat'

    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            $args = [ 'Interface "eth0"',
                      'Map "rx_bytes" "derive" "rx_bytes"',
                      'Map "tx_bytes" "derive" "tx_bytes"',
                      'MappedOnly true', ]
        }
        default: {fail("Collectd plugin ${title} is not supported with ${::operatingsystem}")}
    }

    collectd::util::config_gen {$plugin_name: arg_array => $args}
}
