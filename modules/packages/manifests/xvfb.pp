class packages::xvfb {
    case $::operatingsystem {
        CentOS: {
            package {
                "xorg-x11-server-Xvfb":
                    ensure => latest;
                "xorg-x11-xauth":
                    ensure => latest;
            }
        }
        Ubuntu: {
            package {
                ["xauth", "xvfb"]:
                    ensure => latest;
            }
        }
        Darwin: {
            # N/A
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
