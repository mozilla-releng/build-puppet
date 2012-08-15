class packages::mod_passenger {
    case $operatingsystem {
        CentOS: {
            package {
                "mod_passenger":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
