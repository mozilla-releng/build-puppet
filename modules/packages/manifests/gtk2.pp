class packages::gtk2 {
    case $operatingsystem {
        CentOS: {
            package {
                "gtk2":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
