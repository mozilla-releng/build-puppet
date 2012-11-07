class bmm {
    include dirs::opt::bmm

    include bmm::httpd
    include bmm::tftpd
    include bmm::rsyslog
}
