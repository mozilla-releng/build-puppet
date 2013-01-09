# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
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

    # Nodes running IPMI-compliant hardware should install OpenIPMI
    if (($::manufacturer == "HP" and $::productname =~ /ProLiant/) or
        ($::manufacturer == "iXsystems" and $::productname == "iX700-C") or
        ($::manufacturer == "iXsystems" and $::productname == "iX21X4-STIBTRF")) {
        include packages::openipmi
    }
}
