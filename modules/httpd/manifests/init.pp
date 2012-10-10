class httpd {
    include packages::httpd

    case $operatingsystem {

        Darwin : {
            service {
                'org.apache.httpd' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running ;
            }
        }

        CentOS : {
            service {
                'httpd' :
                    require => Class["packages::httpd"],
                    enable => true,
                    ensure => running;
            }
        }
    }
}

