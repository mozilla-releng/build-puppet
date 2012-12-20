class packages::mysql {
    case $operatingsystem {
        CentOS: {
            package {
                "mysql":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}

