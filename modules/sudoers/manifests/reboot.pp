class sudoers::reboot {
    include sudoers
    include sudoers::settings
    include config
    file {
        "/etc/sudoers.d/reboot" :
            mode => $sudoers::settings::mode,
            owner => $sudoers::settings::owner,
            group => $sudoers::settings::group,
            ensure => file,
            content => "${::config::builder_username} ALL=NOPASSWD: /usr/bin/reboot\n" ;
    }
}