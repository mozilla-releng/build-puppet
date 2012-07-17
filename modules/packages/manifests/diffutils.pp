class packages::diffutils {
    case $operatingsystem {
        CentOS: {
            package {
                "diffutils":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
