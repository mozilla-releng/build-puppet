class packages::mysql-devel {
    case $operatingsystem {
        CentOS: {
            package {
                "mysql-devel":
                    ensure => latest;
            }
        }
        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
