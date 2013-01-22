class packages::patch {
    case $::operatingsystem {
        CentOS: {
            package {
                "patch":
                    ensure => latest;
            }
        }
         Darwin: {
            #patch is installed with base image
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
