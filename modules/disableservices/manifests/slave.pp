class disableservices::slave inherits disableservices::common {
    # This class disables unnecessary services on the slave

    case $operatingsystem {
        CentOS: {
            service { ['iptables','ip6tables']:
                enable => false,
                ensure => stopped,
            }
        }
    }
}

