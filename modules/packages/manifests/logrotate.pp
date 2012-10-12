class packages::logrotate {
    case $operatingsystem {
        CentOS: {
            package {
                "logrotate":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
