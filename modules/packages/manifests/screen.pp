class packages::screen {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            package {
                "screen":
                    ensure => latest;
            }
        }
        Darwin : {
            # installed by default
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
