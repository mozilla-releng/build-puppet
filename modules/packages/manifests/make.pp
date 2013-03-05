class packages::make {
    case $operatingsystem {
        CentOS: {
            package {
                "make":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
