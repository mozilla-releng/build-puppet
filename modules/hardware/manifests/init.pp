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
}
