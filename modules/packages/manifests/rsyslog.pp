class packages::rsyslog {
    case $::operatingsystem {
        CentOS: {
            package {
                "rsyslog":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}


