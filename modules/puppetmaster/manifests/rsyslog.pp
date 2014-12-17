# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::rsyslog {
    include ::config
    include ::rsyslog

    $server = $::config::puppetmaster_syslog_server
    if ($server != '') {
        rsyslog::config {
            "puppetmaster_rsyslog.conf" :
                contents => template("${module_name}/puppetmaster_rsyslog.conf.erb");
        }
    }
}
