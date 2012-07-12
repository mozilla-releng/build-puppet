class packages::screen {
    case $operatingsystem {
        CentOS: {
            package {
                "screen":
                    ensure => latest;
            }
        }
        Darwin : {
            # installed by default
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
