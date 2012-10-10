define httpd::config ($file = $title, $contents = '') {
    case $operatingsystem {
        Darwin : {
            include httpd
            include packages::httpd
            include httpd::settings
            if ($file != undef) and ($contents != undef) {
                file {
                    "$file" :
                        notify => Service['org.apache.httpd'],
                        require => Class['packages::httpd'],
                        path => "/etc/apache2/other/$file",
                        mode => "$httpd::settings::mode",
                        owner => "$httpd::settings::owner",
                        group => "$httpd::settings::group",
                        content => $contents ;
                }
            }
        }
        CentOS : {
            include httpd
            include packages::httpd
            include httpd::settings
            if ($file != undef) and ($contents != undef) {
                file {
                    "$file" :
                        notify => Service['httpd'],
                        require => Class['packages::httpd'],
                        path => "/etc/httpd/conf.d/$file",
                        mode => "$httpd::settings::mode",
                        owner => "$httpd::settings::owner",
                        group => "$httpd::settings::group",
                        content => $contents ;
                }
            }
        }
    }
}
