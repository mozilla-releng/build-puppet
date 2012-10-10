define rsyslog::config ($file = $title, $contents = '') {
    include rsyslog
    include packages::rsyslog
 
    case $operatingsystem {
        CentOS : {
            include rsyslog::settings

            if ($file != undef) and ($contents != undef) {
                file {
                    "$file" :
                        notify => Service['rsyslog'],
                        path => "/etc/rsyslog.d/$file",
                        mode => "$rsyslog::settings::mode",
                        owner => "$rsyslog::settings::owner",
                        group => "$rsyslog::settings::group",
                        content => $contents ;
                }
            }
        }
    }
}
