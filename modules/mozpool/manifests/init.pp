class mozpool {
    include mozpool::settings
    include mozpool::virtualenv
    include mozpool::config
    include mozpool::daemon
    include mozpool::httpd

    file {
        $mozpool::settings::root:
            ensure => directory;
    }

    include nrpe::check::swap
    include nrpe::check::ntp_time

    # remove remnants of bmm (not needed for long)
    file {
        "/etc/cron.d/bmm-inventorysync":
            ensure => absent;
        "/opt/bmm/frontend":
            ensure => absent,
            recurse => true,
            force => true;
    }
}
