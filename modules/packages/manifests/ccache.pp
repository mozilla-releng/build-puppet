class packages::ccache {
    case $operatingsystem {
        CentOS: {
            package {
                "ccache":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
