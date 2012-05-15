class sudoers {

    package {
        "sudo":
            ensure => latest;
    }

    file {
        "sudoers":
            path => "/etc/sudoers",
            require => Package[sudo],
            mode => "440",
            owner => root,
            group => root,
            source => "puppet:///modules/sudoers/sudoers";

        "/etc/sudoers.d":
            require => Package[sudo],
            recurse => true,
            purge => true,
            owner => root,
            group => root,
            ensure => directory;
    }
}
