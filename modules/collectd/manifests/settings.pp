# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class collectd::settings {
    include ::config

    $graphite_cluster_fqdn = $::config::collectd_graphite_cluster_fqdn

    # a defined graphite cluster is a requirement for collectd to be enabled
    if $graphite_cluster_fqdn and $graphite_cluster_fqdn != "" {
        $collectd_enabled = true
    }

    if !$::config::collectd_graphite_port or $::config::collectd_graphite_port == "" {
        # Defualt carbon port
        $graphite_port = "2003"
    }
    else {
        $graphite_port = $::config::collectd_graphite_port
    }

    if !$::config::collectd_graphite_prefix {
        $graphite_prefix = ""
    }
    else {
        $graphite_prefix = $::config::collectd_graphite_prefix
    }

    $syslog_level = "info"
    $global_poll_interval = 25

    case $::operatingsystem {
        'CentOS': {
            $servicename      = 'collectd'
            $configdir        = '/etc'
            $plugindir        = '/etc/collectd.d'
        }
        'Ubuntu': {
            $servicename      = 'collectd'
            $configdir        = '/etc/collectd'
            $plugindir        = '/etc/collectd/collectd.d'
        }
        'Darwin': {
            $servicename      = 'org.collectd.collectd'
            $configdir        = '/usr/local/etc'
            $plugindir        = '/usr/local/etc/collectd.d'
        }
        default: {
            fail("This OS is not supported for collectd")
        }
    }
}

