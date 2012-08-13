class smarthost::daemon {
    service { "postfix":
        ensure => running,
        hasstatus => true,
        hasrestart => true,
        enable => true,
        require => Class["smarthost::setup"],
    }
}
