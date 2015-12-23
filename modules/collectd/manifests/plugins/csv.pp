# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::csv {
    include collectd
    include collectd::settings

    # https://collectd.org/wiki/index.php/Plugin:CSV

    $plugin_name = 'csv'

    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            $args =  ['DataDir "/var/lib/collectd/csv"',
                      'StoreRates true', ]
        }
        'Darwin': {
            $args =  ['DataDir "/usr/local/var/lib/collectd/csv"',
                      'StoreRates true', ]
        }
        default: {fail("Collectd plugin ${title} is not supported with ${::operatingsystem}")}
    }

    collectd::util::config_gen {$plugin_name: arg_array => $args}
}
