class tweaks::rc_local {

    case $::operatingsystem {
        CentOS: {
            file {
                "/etc/rc.local":
                    source => "puppet:///modules/tweaks/rc.local",
                    mode => 755;
                "/etc/init.d/rc.local":
                    source  => "puppet:///modules/tweaks/rc.local.init.d",
                    require => File['/etc/rc.local'],
                    mode    => 755;
            }
            service {
                "rc.local":
                    enable => true,
                    require => File['/etc/init.d/rc.local'];
            }
        }
    }
}
