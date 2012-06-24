class packages::editors {
    case $operatingsystem {
        CentOS: {
            package {
                "nano":
                    ensure => latest;
                "vim-minimal":
                    ensure => latest;
            }
        }
 
        Darwin: {
            # installed by default
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
