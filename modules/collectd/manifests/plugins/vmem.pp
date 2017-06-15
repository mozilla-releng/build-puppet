# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::vmem {
    include collectd
    include collectd::settings

    # https://collectd.org/wiki/index.php/Plugin:vmem

    $plugin_name = 'vmem'

    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            $args = [ 'Verbose true', ]
        }
        default: {fail("Collectd plugin ${title} is not supported with ${::operatingsystem}")}
    }

    collectd::util::config_gen {$plugin_name: arg_array => $args}
}
