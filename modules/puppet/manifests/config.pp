class puppet::config {
    file {
        "/etc/puppet/puppet.conf":
            content => template("puppet/puppet.conf.erb");
    }
}
