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
    $global_poll_interval = 60

    # WriteQueueLimitHigh and WriteQueueLimitLow are set equal so metrics are not
    # randomly dropped between the thresholds.
    $global_write_queue_limit_high = 6000
    $global_write_queue_limit_low = 6000

    case $::operatingsystem {
        'CentOS': {
            $servicename      = 'collectd'
            $configdir        = '/etc'
            $plugindir        = '/etc/collectd.d'
            $servicepath      = undef
            $servicescript    = undef
        }
        'Ubuntu': {
            $servicename      = 'collectd'
            $configdir        = '/etc/collectd'
            $plugindir        = '/etc/collectd/collectd.d'
            $servicepath      = undef
            $servicescript    = undef
        }
        'Darwin': {
            $servicename      = 'org.collectd.collectd'
            $configdir        = '/usr/local/etc'
            $plugindir        = '/usr/local/etc/collectd.d'
            $servicepath      = '/Library/LaunchDaemons'
            $servicescript    = 'org.collectd.collectd.plist'
        }
        default: {
            fail("This OS is not supported for collectd")
        }
    }
}

