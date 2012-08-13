class packages::mailx {
    case $operatingsystem {
        CentOS: {
            package {
                "mailx":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}


