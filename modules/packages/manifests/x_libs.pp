class packages::x_libs {
    case $operatingsystem {
        CentOS: {
            package {
                "libXt":
                    ensure => latest;
                "libXext":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
