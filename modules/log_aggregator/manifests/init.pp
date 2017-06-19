# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class log_aggregator {
    include ::config
    include ::rsyslog
    include ::dirs::opt
    include nrpe::check::open_tcp
    include packages::rsyslog_gnutls

    file {
        '/var/spool/rsyslog':
            ensure => directory;
        '/etc/papertrail-bundle.pem':
            mode   => '0644',
            source => 'puppet:///modules/log_aggregator/etc/papertrail-bundle.pem';
        '/etc/security/limits.conf':
            mode   => '0644',
            source => 'puppet:///modules/log_aggregator/etc/limits.conf';
    }

    $cef_syslog_server = $::config::cef_syslog_server
    $logging_port      = $::config::logging_port

    rsyslog::config {
        '00-papertrail' :
            # note: diffs will not be shown
            contents => template("${module_name}/papertrail.conf.erb");
    }
}
