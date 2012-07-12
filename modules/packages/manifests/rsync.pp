class packages::rsync {
    case $operatingsystem {
        CentOS: {
            package {
                "rsync":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
