class mozpool {
    include nrpe::check::procs_regex
    include mozpool::settings
    include mozpool::virtualenv
    include mozpool::config
    include mozpool::daemon
    include mozpool::httpd

    file {
        $mozpool::settings::root:
            ensure => directory;
    }


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
