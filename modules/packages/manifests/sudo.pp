class packages::sudo {
    case $::operatingsystem {
        CentOS, Ubuntu : {
            package {
                "sudo" :
                    ensure => latest ;
            }
        }
        Darwin : {
        # installed by default

        }
        default : {
            fail("cannot install on $::operatingsystem")
        }
    }
}
