class sudoers {
        include sudoers::settings
        include packages::sudo

        file {
                "sudoers" :
                    require => Class['packages::sudo'],
                        path => "/etc/sudoers",
                        mode => "$sudoers::settings::mode",
                        owner => "$sudoers::settings::owner",
                        group => "$sudoers::settings::group",
                        source => "puppet:///modules/sudoers/sudoers.$operatingsystem" ;

                "/etc/sudoers.d" :
                    require => Class['packages::sudo'],
                        recurse => true,
                        purge => true,
                        owner => "$sudoers::settings::owner",
                        group => "$sudoers::settings::group",
                        ensure => directory ;
        }
}






