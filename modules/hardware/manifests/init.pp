# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class hardware {
    include config

    # HP Proliant systems get the hp-health utility, and nagios checks
    # to query it
    # This IF code block should be removed soon since we don't use the
    # hp-health package anymore.
    # https://bugzilla.mozilla.org/show_bug.cgi?id=883318
    if ($::manufacturer == "HP" and $::productname =~ /ProLiant/) {
        include packages::hp_health
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
        # iX700-C's can show up as X8SIL, too
        ($::manufacturer == "iXsystems" and $::productname == "X8SIL") or
        ($::manufacturer == "iXsystems" and $::productname == "iX21X4-STIBTRF")) {
        include packages::openipmi
    }

    # some iX hardware shows up as 'ixSystems', some as 'Supermicro'
    if (($::manufacturer == 'iXsystems' or $::manufacturer == 'Supermicro') and
        # iX700-C's can show up as X8SIL, too
        ($::productname == "iX700-C" or $::productname == "X8SIL" or $::productname == "iX21X4-STIBTRF")) {
        include tweaks::i82574l_aspm
    }

    # OK, so it's not strictly "hardware", but stlil..
    if ($::virtual == "vmware") {
        if ($config::vmwaretools_version) {
            class {
                'vmwaretools':
                    version => $config::vmwaretools_version,
                    archive_md5 => $config::vmwaretools_md5,
                    archive_url => "http://${config::data_server}/repos/private/vmware";
            }
        }
    }
}
