class blackmobilemagic::config::rsyslog {
    include ::rsyslog
    include packages::logrotate

    rsyslog::config {
        "bmm_rsyslog.conf" :
            contents => template("blackmobilemagic/bmm_rsyslog.conf.erb"),
            need_mysql => true;
    }

    file {
        "/etc/logrotate.d/boards":
            source => "puppet:///blackmobilemagic/logrotate_boards",
            require => Class['packages::logrotate'];
    }
}

