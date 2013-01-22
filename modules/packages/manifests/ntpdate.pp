class packages::ntpdate {
    case $::operatingsystem {
        Ubuntu: {
            package {
                "ntpdate":
                    ensure => latest;
            }
        }
        Darwin, CentOS: {
            # Ignore known OSes
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
