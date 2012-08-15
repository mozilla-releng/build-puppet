class packages::diffutils {
    case $operatingsystem {
        CentOS: {
            package {
                "diffutils":
                    ensure => latest;
            }
        }
        Darwin: {
            # installed by default on Darwin
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
