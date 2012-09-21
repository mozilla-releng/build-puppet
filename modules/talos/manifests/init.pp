class talos {
	include talos::settings 
	include httpd 
	include packages::xcode_cmdline_tools
	include packages::java
	include users::builder 
	include dirs::builds::slave
	
	case $operatingsystem {
		Darwin : {
			file {
				"/builds/slave/talos-slave" :
					ensure => directory,
					owner => "$users::builder::username",
					group => "$users::builder::group",
					mode => 0755 ;
			}
			file {
				"/builds/slave/talos-slave/talos-data" :
					ensure => directory,
					owner => "$users::builder::username",
					group => "$users::builder::group",
					mode => 0755 ;
			}
			file {
				$talos::settings::apachedocumentroot :
					ensure => directory,
					owner => "$users::builder::username",
					group => "$users::builder::group",
					mode => 0755 ;
			}
			httpd::config {
				"talos.conf" :
					contents => template("talos/talos-httpd.conf.erb") ;
			}
		}
	}
	}
