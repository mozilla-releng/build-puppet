class nrpe::install {
    case $operatingsystem {
        CentOS: {
            package {
                "nrpe":
                    ensure => latest;
                "nagios-plugins-nrpe":
                    ensure => latest;
                "nagios-plugins-all":
                    ensure => latest;
            }
        }
    }
}
