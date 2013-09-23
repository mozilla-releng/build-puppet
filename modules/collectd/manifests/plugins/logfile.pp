# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class collectd::plugins::logfile {
    include collectd
    include collectd::settings

    # https://collectd.org/wiki/index.php/Plugin:LogFile
    $plugin_name = 'logfile'

    case $::operatingsystem {
        'CentOS', 'Ubuntu', 'Darwin': {
            $args = [ 'LogLevel info',
                      'File "/var/log/collectd.log"',
                      'TimeStamp true',
                      'PrintSeverity true', ]
        }
        default: {fail("Collectd plugin ${title} is not supported with ${::operatingsystem}")}
    }

    collectd::util::config_gen {$plugin_name: arg_array => $args}
}
