class packages::postfix {
    case $operatingsystem {
        CentOS: {
            package {
                "postfix":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}

