class puppet::config {
    include ::config

    file {
        "/etc/puppet/puppet.conf":
            content => template("puppet/puppet.conf.erb");
    }
}
