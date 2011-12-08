class ntp::daemon {
    # NTP daemons don't work on VMWare, so don't install them there
    if ($::virtual != "vmware") {
        include packages::ntp

        $group = $operatingsystem ? {
            Darwin => wheel,
            default => root
        }

        file {
            "/etc/ntp.conf":
                content => template("ntp/ntp.conf.erb"),
                mode => 644,
                owner => root,
                group => $group;
        }

        service {
            "ntpd": 
                subscribe => File["/etc/ntp.conf"],
                enable => true,
                hasstatus => true,
                ensure => running;
            "ntpdate": 
                enable => true,
                hasstatus => false;
        }
    } else {
        # actively disable ntp on virtual machines, just in case
        service {
            "ntpd": 
                enable => false,
                hasstatus => true,
                ensure => stopped;
            "ntpdate": 
                enable => false,
                hasstatus => false;
        }
    }
}
