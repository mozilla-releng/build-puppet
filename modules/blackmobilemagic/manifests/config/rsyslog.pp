class blackmobilemagic::config::rsyslog {
    include ::rsyslog

    rsyslog::config {
        "bmm_rsyslog.conf" :
            contents => template("blackmobilemagic/bmm_rsyslog.conf.erb");
    }

    file {
       "/opt/bmm/logs":
            ensure => directory;
    }
}

