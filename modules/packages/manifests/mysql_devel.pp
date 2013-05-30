class packages::mysql_devel {
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
