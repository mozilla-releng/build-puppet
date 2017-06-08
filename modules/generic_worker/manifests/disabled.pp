class generic_worker::disabled {

    case $::operatingsystem {
        Darwin: {
            file { '/Library/LaunchAgents/net.generic.worker.plist':
                ensure => absent,
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}

