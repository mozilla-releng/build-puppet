class toplevel::server::master inherits toplevel::server {
    # incomplete

    # this might be too much - check before using
    # also, note check_mysql doesn't work yet
    include nrpe::check::buildbot
    include nrpe::check::ide_smart
    include nrpe::check::procs_regex
    include nrpe::check::child_procs_regex
    include nrpe::check::swap
    include nrpe::check::mysql
    include nrpe::check::ntp_time
    include nrpe::check::http_redirect_ip
    include nrpe::check::ganglia
}
