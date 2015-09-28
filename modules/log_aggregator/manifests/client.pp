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
            Windows: {
                include ::nxlog
                include nxlog::settings
                case $::operatingsystemrelease {
                    # Windows Server 2008 ec2
                    "2008 R2", "6.1.7601": {
                        file {
                            "${nxlog::settings::root_dir}/conf/nxlog_source_eventlog.conf":
                                require => Class [ 'packages::nxlog' ],
                                content => template('nxlog/nxlog_source_eventlog_win2008_ec2.conf.erb'),
                                notify => Service [ 'nxlog' ];
                        }
                    }
                    # Windows Server 2008 ix
                    "1.0.11(0.46/3/2)": {
                        file {
                            "${nxlog::settings::root_dir}/conf/nxlog_source_eventlog.conf":
                                require => Class [ 'packages::nxlog' ],
                                content => template('nxlog/nxlog_source_eventlog_win2008_ix.conf.erb'),
                                notify => Service [ 'nxlog' ];
                        }
                    }
                    default: {
                        # if the error message below is appearing in puppet logs, add a filtered configuration,
                        # tailored to the OS version shown in the error message (like the one above for "6.1.7601").
                        fail("No nxlog eventlog filter found for OS: ${::operatingsystem}, version: ${::operatingsystemrelease}")
                    }
                }
                file {
                    "${nxlog::settings::root_dir}/conf/nxlog_transform_syslog.conf":
                        require => Class [ 'packages::nxlog' ],
                        content => template('nxlog/nxlog_transform_syslog.conf.erb'),
                        notify => Service [ 'nxlog' ];
                    "${nxlog::settings::root_dir}/conf/nxlog_target_aggregator.conf":
                        require => Class [ 'packages::nxlog' ],
                        content => template('nxlog/nxlog_target_aggregator.conf.erb'),
                        notify => Service [ 'nxlog' ];
                    "${nxlog::settings::root_dir}/conf/nxlog_route_eventlog_aggregator.conf":
                        require => Class [ 'packages::nxlog' ],
                        content => template('nxlog/nxlog_route_eventlog_aggregator.conf.erb'),
                        notify => Service [ 'nxlog' ]
                }
            }
            default: {
                fail("Not supported on ${::operatingsystem}")
            }
        }
    }
}
