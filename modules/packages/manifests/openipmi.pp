class packages::openipmi {
    case $::operatingsystem {
        CentOS: {
            package {
                [ "OpenIPMI",
                  "ipmitool",
                ]:
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
