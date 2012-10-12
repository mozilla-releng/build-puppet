class packages::rsyslog_mysql {
    include packages::rsyslog
    case $operatingsystem {
        CentOS: {
            package {
                "rsyslog-mysql":
                    ensure => latest,
                    require => Class['packages::rsyslog'];
            }
        }

        default: {
            fail("cannot install on $operatingsystem")
        }
    }
}
