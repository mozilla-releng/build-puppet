class packages::xinetd {
    case $operatingsystem {
        CentOS: {
            package {
                "xinetd":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}


