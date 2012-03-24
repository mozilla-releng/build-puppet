class network {
    # ensure that the host uses its fqdn
    case $operatingsystem {
        CentOS: {
            # always set the hostname to the fqdn
            file {
                "/etc/sysconfig/network":
                    content => "NETWORKING=yes\nHOSTNAME=$fqdn\n",
                    notify => Exec['run-hostname-centos'];
            }

            exec {
                "run-hostname-centos":
                    command => "/bin/hostname $fqdn",
                    refreshonly => true;
            }

            # and ensure we don't use peer NTP configuration (as that comes from puppet)
            file {
                "/etc/sysconfig/network-scripts/ifcfg-eth0":
                    content => template("network/centos6-ifcfg-eth0.erb");
            }
        }
    }

}
