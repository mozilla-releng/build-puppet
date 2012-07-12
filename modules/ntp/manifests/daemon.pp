class ntp::daemon {

# NTP daemons don't work on VMWare, so don't install them there
	if ($::virtual != "vmware") {
        include ::shared
		include packages::ntp
		include config 
		include users::settings
		 
		$ntpserver = $config::ntp_server
		
		case $operatingsystem {
			CentOS : {
				file {
					"/etc/ntp.conf" :
						content => template("ntp/ntp.conf.erb"),
						mode => 644,
						owner => root,
						group => $::shared::root_group;
				}
				service {
					"ntpd" :
						subscribe => File["/etc/ntp.conf"],
						enable => true,
						hasstatus => true,
						ensure => running ;
				}
			}
			Darwin : {
				service {
					"ntpdate" :
						enable => true,
						hasstatus => true ;
				}
				exec {
					"set-time-server" :
						command => "/usr/sbin/systemsetup -setnetworktimeserver ${ntpserver}",
						refreshonly => true ;
				}
				file {
					"$users::settings::home_dir/.puppet-ntpserver" :
						content => "$ntpserver",
						notify => Exec["set-time-server"] ;
				}
			}
		}
	}
	else {
	# actively disable ntp on virtual machines, just in case
		service {
			"ntpd" :
				enable => false,
				hasstatus => true,
				ensure => stopped ;

			"ntpdate" :
				enable => false,
				hasstatus => false ;
		}
	}
}


