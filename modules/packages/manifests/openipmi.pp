class packages::openipmi {
    case $operatingsystem {
        CentOS: {
            package {
                "OpenIPMI":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
