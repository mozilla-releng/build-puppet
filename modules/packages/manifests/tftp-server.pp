class packages::tftp-server {
    include packages::xinetd
 
    case $::operatingsystem {
        CentOS: {
            package {
                "tftp-server":
                    ensure => latest,
                    require => Class["packages::xinetd"];
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}


