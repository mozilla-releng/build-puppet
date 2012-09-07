class hardware {
    # HP Proliant systems get the hp-health utility, and nagios checks
    # to query it
    if ($::manufacturer == "HP" and $::productname =~ /ProLiant/) {
        include packages::hp_health
        include nrpe::check::hpasm
        include nrpe::check::hplog

        service {
            [ 'hp-asrd', 'hp-health' ]:
                ensure => running,
                enable => true,
                require => Class['packages::hp_health'];
        }
    }

    # SeaMicro nodes can start up with incorrect time - see bug 789064
    if ($::manufacturer == "SeaMicro" and $::productname == "SM10000-XE") {
        # only known to work on CentOS so far, although it should work on any Linux
        if ($::operatingsystem == "CentOS") {
            file {
                "/etc/e2fsck.conf":
                    source => "puppet:///modules/hardware/seamicro-e2fsck.conf";
            }
        }
    }
}
