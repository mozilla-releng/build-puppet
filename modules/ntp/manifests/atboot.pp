class ntp::atboot {
    case $::operatingsystem {
        CentOS, Darwin: {
            include packages::ntp
            service {
                "ntpdate":
                    enable => true,
                    hasstatus => false;
            }
        }
        Ubuntu: {
            include config
            include packages::ntpdate
            # ntpdate is run by if-up
            file {
                "/etc/default/ntpdate":
                    content => template("ntp/ntpdate.default.erb");
            }
        }
        default: {
            fail("cannot instantiate on $::operatingsystem")
        }
    }
}
