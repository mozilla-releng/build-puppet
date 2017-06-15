# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class collectd::profiles {
    include collectd
    include collectd::settings
    include stdlib

    # do not configure unless graphite server is defined
    if $collectd::settings::collectd_enabled == true {
        include packages::collectd

        # This is an array of generic plugins which are common
        # to all operating systems collectd supports
        # Generic plugins are ones which do not need unique
        # configuration arguments and can be included using the
        # collectd::plugins::generic class

        $common_plugins = [ 'memory', 'swap', 'uptime', 'load', ]

        # Here we include plugins based on OS since some plugins
        # may not be compatible with certain operation systems
        # We also define any os specific generic plugins

        case $::operatingsystem {
            'CentOS', 'Ubuntu': {
                $os_generic_plugins = []
                include collectd::plugins::cpu
                include collectd::plugins::disk
                include collectd::plugins::df
                include collectd::plugins::interface
                include collectd::plugins::ethstat
                include collectd::plugins::statsd
            }
            'Darwin': {
                $os_generic_plugins = []
                include collectd::plugins::cpu
                include collectd::plugins::df
                include collectd::plugins::interface
                include collectd::plugins::statsd
            }
            default: { fail("OS profile not found in ${title}") }
        }

        # Combine the $common_plugins and $os_generic_plugins
        # and configure them with the collectd::plugins::generic
        # parameterized class

        $plugins = concat($common_plugins, $os_generic_plugins)
        class {'collectd::plugins::generic':
            plugins => $plugins, }

        # write plugins 
        class { 'collectd::plugins::write_graphite':
            nodes => $collectd::settings::write['graphite_nodes'], }
        # TODO: this should pass an array of all write chains, not just graphite nodes
        class { 'collectd::plugins::filters':
            write_chains => $collectd::settings::write['graphite_nodes'], }
    }
}

