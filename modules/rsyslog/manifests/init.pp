class rsyslog {
    include packages::rsyslog

    case $operatingsystem {
        CentOS : {
            service { "rsyslog":
               require => Class["packages::rsyslog"],
               ensure => running,
               enable => true;
            }
            file {
                "/etc/rsyslog.conf":
                    ensure => present,
                    source => "puppet:///modules/rsyslog/rsyslog.conf",
                    notify => Service["rsyslog"];
                "/etc/rsyslog.d/":
                    ensure => directory,
                    notify => Service["rsyslog"];
            }
        }
    }
}
