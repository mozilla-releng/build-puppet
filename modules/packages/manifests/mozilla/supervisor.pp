class packages::mozilla::supervisor {
    case $operatingsystem {
        CentOS: {
            package {
                "supervisor":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
