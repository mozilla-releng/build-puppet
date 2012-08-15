class sudoers::reboot {
    include sudoers
    include sudoers::settings
    include config
    include users::builder

    file {
        "/etc/sudoers.d/reboot" :
            mode => $sudoers::settings::mode,
            owner => $sudoers::settings::owner,
            group => $sudoers::settings::group,
            ensure => file,
            content => "${users::builder::username} ALL=NOPASSWD: $sudoers::settings::rebootpath\n" ;
    }
}
