class httpd {
    include packages::httpd

    case $::operatingsystem {
        Darwin: {
            service {
                'org.apache.httpd' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running ;
            }
        }
        CentOS: {
            service {
                'httpd' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running;
            }
        }
        Ubuntu: {
            service {
                'apache2' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running;
            }
        }
        default: {
            fail("Don't know how to set up httpd on $::operatingsystem")
        }
    }
}

