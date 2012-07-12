class packages::nslookup {
    case $operatingsystem {
        CentOS: {
            package {
                "bind-utils":  #Provided by bind-utils
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
