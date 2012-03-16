class network {
    # ensure that the host uses its fqdn
    case $operatingsystem {
        CentOS: {
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
        }
    }

}
