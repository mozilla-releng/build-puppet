# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::interface {
    include collectd
    include collectd::settings

    # https://collectd.org/wiki/index.php/Plugin:Interface

    $plugin_name = 'interface'

    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            $args = [ 'Interface "lo"',
                      'IgnoreSelected true', ]
        }
        'Darwin': {
            $args = [ 'Interface "lo0"',
                      'IgnoreSelected true', ]
        }
        default: {fail("Collectd plugin ${title} is not supported with ${::operatingsystem}")}
    }

    collectd::util::config_gen {$plugin_name: arg_array => $args}
}
