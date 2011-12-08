class packages::ntp {
    case $operatingsystem {
        CentOS: {
            package {
                "ntp":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
