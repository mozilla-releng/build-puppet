class packages::alsa {
    case $::operatingsystem {
        CentOS: {
            package {
                "alsa-lib":
                    ensure => latest;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
