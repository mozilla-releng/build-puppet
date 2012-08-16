class disableservices::iptables {
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

