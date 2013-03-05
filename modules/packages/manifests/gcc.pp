class packages::gcc {
    case $operatingsystem {
        CentOS: {
            package {
                "gcc":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
