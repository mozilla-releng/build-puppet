class packages::vncserver {
    case $::operatingsystem {
        Ubuntu: {
            package {
                "x11vnc":
                    ensure => latest;
            }
        }
        Darwin: {
            # VNC is installed by default
        }
        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}
