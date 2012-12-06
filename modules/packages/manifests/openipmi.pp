class packages::openipmi {
    case $operatingsystem {
        CentOS: {
            package {
                [ "OpenIPMI",
                  "OpenIPMI-tools",
                ]:
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
