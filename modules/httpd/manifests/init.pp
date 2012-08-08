class httpd {
        case $operatingsystem {
                Darwin : {
                        include packages::httpd
              
                        service {
                                'org.apache.httpd' :
                                        enable => true,
                                        ensure => running ;
                        }
                }
        }
}

