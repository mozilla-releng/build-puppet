class bmm::rsyslog {
    include ::rsyslog
    include packages::logrotate
    include ::config::secrets

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

