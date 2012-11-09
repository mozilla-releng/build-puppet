class bmm {
    include dirs::opt::bmm

    include bmm::httpd
    include bmm::tftpd
    include bmm::rsyslog

    include nrpe::check::procs_regex
    include nrpe::check::swap
    include nrpe::check::ntp_time
}
