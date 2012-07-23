class buildslave::startup::initd {
    file {
        "/etc/init.d/buildbot":
            content => template("buildslave/linux-initd-buildbot.sh.erb"),
            owner  => "root",
            group  => "root",
            mode => 755;
    }

    service {
        "buildbot":
            enable => true,
            require => [
                File['/etc/init.d/buildbot'],
                File['/usr/local/bin/runslave.py'],
                Class['buildslave::install'],
            ];
    }
}
