class packages::pango {
    case $operatingsystem {
        CentOS: {
            package {
                "pango":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
