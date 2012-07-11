class packages::supervisord {
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
