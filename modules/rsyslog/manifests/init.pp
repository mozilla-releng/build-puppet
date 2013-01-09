# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class rsyslog {
    include packages::rsyslog

    case $::operatingsystem {
        CentOS : {
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
                    notify => Service["rsyslog"];
            }
        }
    }
}
