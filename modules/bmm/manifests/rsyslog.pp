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

