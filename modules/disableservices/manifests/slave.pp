class disableservices::slave inherits disableservices::common {
    # This class disables unnecessary services on the slave

    include disableservices::iptables
    include disableservices::displaymanager
}

