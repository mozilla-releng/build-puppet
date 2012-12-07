class mozpool {
    include mozpool::settings
    include mozpool::virtualenv
    include mozpool::config
    include mozpool::daemon
    include mozpool::httpd
    include mozpool::inventorysync
    include mozpool::dbcron

    file {
        $mozpool::settings::root:
            ensure => directory;
    }

    include nrpe::check::swap
    include nrpe::check::ntp_time
}
