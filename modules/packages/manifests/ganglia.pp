class packages::ganglia {
    case $::operatingsystem {
        CentOS: {
            package {
                "ganglia-gmond":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
