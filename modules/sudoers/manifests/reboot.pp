class sudoers::reboot {
    include sudoers
    include config

    file {
        "/etc/sudoers.d/reboot":
            require => Package[sudo],
            mode => "440",
            owner => root,
            group => root,
            ensure => file,
            content => "${::config::builder_username} ALL=NOPASSWD: /usr/bin/reboot\n";
    }
}
