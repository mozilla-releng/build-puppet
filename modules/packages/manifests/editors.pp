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

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
