# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class log_aggregator {
    include ::config
    include ::rsyslog
    include ::dirs::opt

    file {
        "/opt/aggregator":
            ensure => directory;
        "/opt/aggregator/bin":
            ensure => directory;
        "/opt/aggregator/bin/rotate":
            mode => '0755',
            source => 'puppet:///modules/log_aggregator/bin/rotate';
        "/opt/aggregator/log":
            ensure => directory;
    }

    rsyslog::config {
        "log_aggregator_aggregator" :
            contents => template("${module_name}/aggregator.conf.erb");
    }
}
