# Ensure that a buildslave starts up on this machine

class buildslave::startup {
    include ::shared
    include buildslave::install

    $startuptype = $operatingsystem ? {
        CentOS      => "initd",
        # not done in PuppetAgain yet:
        #Fedora      => "desktop",
        #Darwin      => "launchd"
    }

    # everyone uses runslave.py in the same place
    file {
        "/usr/local/bin/runslave.py":
            source => "puppet:///modules/buildslave/runslave.py",
            owner  => "root",
            group => $::shared::root_group,
            mode => 755;
    }

    case $startuptype {
        initd: {
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
    }
}

