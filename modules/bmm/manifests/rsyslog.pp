# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class bmm::rsyslog {
    include ::rsyslog
    include packages::logrotate
    include mozpool::settings

    # steal some settings from mozpool
    $db_database = $::mozpool::settings::db_database
    $db_username = $::mozpool::settings::db_username
    $db_password = $::mozpool::settings::db_password
    $db_hostname = $::mozpool::settings::db_hostname

    rsyslog::config {
        "bmm_rsyslog.conf" :
            contents => template("bmm/bmm_rsyslog.conf.erb"),
            need_mysql => true;
    }

    file {
        "/etc/logrotate.d/boards":
            source => "puppet:///modules/bmm/logrotate_boards",
            require => Class['packages::logrotate'];
    }
}
