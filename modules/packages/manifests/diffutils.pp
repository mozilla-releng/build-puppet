class packages::diffutils {
    case $operatingsystem {
        CentOS: {
            package {
                "diffutils":
                    ensure => latest;
            }
        }
        Darwin: {
          # doesn't apply this platform 
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
