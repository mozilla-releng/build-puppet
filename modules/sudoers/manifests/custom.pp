define sudoers::custom($user, $command) {
    include sudoers

    file {
        "/etc/sudoers.d/$title":
            require => Package[sudo],
            mode => "440",
            owner => root,
            group => root,
            ensure => file,
            content => "$user ALL=NOPASSWD: $command\n";
    }
}

