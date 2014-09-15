# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class rsyslog {
    include packages::rsyslog

    case $::operatingsystem {
        CentOS,Ubuntu: {
            service { "rsyslog":
               require => Class["packages::rsyslog"],
               ensure => running,
               enable => true;
            }
            file {
                "/etc/rsyslog.conf":
                    ensure => present,
                    source => "puppet:///modules/rsyslog/rsyslog.conf",
                    notify => Service["rsyslog"];
                "/etc/rsyslog.d/":
                    ensure => directory,
                    notify => Service["rsyslog"],
                    recurse => true,
                    purge => true,
                    force => true;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }

    # CentOS and Ubuntu have different default, local logging configs
    case $::operatingsystem {
        CentOS,Ubuntu: {
            rsyslog::config {
                'default-local-logging':
                    contents => template("${module_name}/rsyslog-${::operatingsystem}.conf.erb");
            }
        }
        default: {
            # do nothing
        }
    }
}
