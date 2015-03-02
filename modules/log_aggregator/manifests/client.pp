# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class log_aggregator::client {
    include ::config

    $log_aggregator = $::config::log_aggregator
    $logging_port = $::config::logging_port


    if (!$is_log_aggregator_host and $log_aggregator and $logging_port) {
        case $::operatingsystem {
            CentOS,Ubuntu: {
                rsyslog::config {
                    "log_aggregator_client" :
                        contents => template("${module_name}/client.conf.erb");
                }
            }
            Darwin: {
                # /etc/syslog.conf is managed whether or not $log_aggregator is set
                file {
                    "/etc/syslog.conf":
                        content => template("${module_name}/darwin_syslog.conf.erb"),
                        mode => '0644',
                        owner => root,
                        group => wheel,
                        notify => Service['com.apple.syslogd'];
                }
                service {
                    'com.apple.syslogd':
                        enable => true,
                        ensure => running;
                }
            }
            default: {
                fail("Not supported on ${::operatingsystem}")
            }
        }
    }
}
