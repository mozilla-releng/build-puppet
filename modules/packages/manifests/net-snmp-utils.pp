class packages::net-snmp-utils {
    case $operatingsystem {
        CentOS: {
            package {
                "net-snmp-utils":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
