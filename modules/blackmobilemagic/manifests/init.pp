class blackmobilemagic {
    include dirs::opt::bmm
    include blackmobilemagic::config::httpd
    include blackmobilemagic::config::tftpd
    include blackmobilemagic::config::rsyslog
    include blackmobilemagic::config::frontend
}
