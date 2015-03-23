# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class log_aggregator {
    include ::config
    include ::rsyslog
    include ::dirs::opt
    include packages::rsyslog_gnutls
    include nrpe::check::ntp_time
    include nrpe::check::ntp_peer
    include nrpe::check::swap

    file {
        "/var/spool/rsyslog":
            ensure => directory;
        "/etc/papertrail-bundle.pem":
            mode => '0644',
            source => 'puppet:///modules/log_aggregator/etc/papertrail-bundle.pem';
    }

    $cef_syslog_server = $::config::cef_syslog_server
    $logging_port = $::config::logging_port

    rsyslog::config {
        "00-papertrail" :
            contents => template("${module_name}/papertrail.conf.erb");
    }
}
