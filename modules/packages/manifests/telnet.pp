class packages::telnet {
    case $operatingsystem {
        CentOS: {
            package {
                "telnet":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
