define sudoers::custom($user, $command) {
    include sudoers
    include packages::sudo

    file {
        "/etc/sudoers.d/$title":
            require => Class['packages::sudo'],
            mode => "440",
            owner => root,
            group => root,
            ensure => file,
            content => "$user ALL=NOPASSWD: $command\n";
    }
}
