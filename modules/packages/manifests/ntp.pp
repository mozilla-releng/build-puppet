class packages::ntp {
    case $::operatingsystem {
        CentOS, Ubuntu: {
            package {
                "ntp":
                    ensure => latest;
            }
        }
        Darwin: {
            #ntpd is installed with base install image
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
