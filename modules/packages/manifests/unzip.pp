class packages::unzip {
    case $operatingsystem {
        CentOS: {
            package {
                "unzip":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
