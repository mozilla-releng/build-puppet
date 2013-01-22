class disableservices::displaymanager {
    # This class disables unnecessary login manager start

    case $::operatingsystem {
        Ubuntu: {
            file {
                # removing the following file disables display manager start
                "/etc/X11/default-display-manager":
                    ensure => absent,
                    force  => true;
            }
        }
        Darwin, CentOS: {
            # N/A
        }
        default: {
            fail("Cant disable DM on $::operatingsystem")
        }
    }
}

