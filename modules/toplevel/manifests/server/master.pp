class toplevel::server::master inherits toplevel::master {
    # incomplete
    include nrpe

    # this might be too much - check before using
    # also, note check_mysql doesn't work yet
    include nagios::check::buildbot
    include nagios::check::ide_smart
    include nagios::check::procs_regex
    include nagios::check::child_procs_regex
    include nagios::check::swap
    include nagios::check::mysql
    include nagios::check::ntp_time
    include nagios::check::http_redirect_ip
    include nagios::check::ganglia
}
