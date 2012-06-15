class disableservices::common {
    # This class disables unnecessary services common to both server and slave

    case $operatingsystem {
        CentOS: {
            service { ['avahi-daemon', 'avahi-dnsconfd', 'bluetooth','sendmail']:
                enable => false,
                ensure => stopped,
            }
        }
        Darwin: {
            service { ['com.apple.screensharing','com.apple.blued']:
               enable => false,
               ensure => stopped,
            }
       }
    }
}
