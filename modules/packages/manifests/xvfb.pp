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

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
