class packages::mock {
    case $::operatingsystem {
        CentOS: {
            package {
                "mock":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
