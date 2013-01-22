class packages::diffutils {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            package {
                "diffutils":
                    ensure => latest;
            }
        }
        Darwin: {
            # installed by default on Darwin
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
