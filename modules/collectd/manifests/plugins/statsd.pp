# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::statsd {
    include collectd
    include collectd::settings

    # https://collectd.org/wiki/index.php/Plugin:StatsD

    $plugin_name = 'statsd'

    case $::operatingsystem {
        'CentOS', 'Ubuntu', 'Darwin': {
            $args = [ 'Host "127.0.0.1"',
                      'Port "8125"',
                      'DeleteCounters true',
                      'DeleteTimers true',
                      'DeleteGauges true',
                      'DeleteSets true',
                      'TimerLower true',
                      'TimerUpper true',
                      'TimerSum false',
                      'TimerCount false',
                      'TimerPercentile 50',
                      'TimerPercentile 95',
            ]
        }
        default: {fail("Collectd plugin ${title} is not supported with ${::operatingsystem}")}
    }

    collectd::util::config_gen {$plugin_name: arg_array => $args}
}
