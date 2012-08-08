define httpd::config ($file = $title, $contents = '') {
	case $operatingsystem {
		Darwin : {
			include packages::httpd 
			include httpd::settings 
			if ($file != undef) and ($contents != undef) {
				file {
					"$file" :
						require => Class['packages::httpd'],
						path => "/etc/apache2/other/$file",
						mode => "$httpd::settings::mode",
						owner => "$httpd::settings::owner",
						group => "$httpd::settings::group",
						content => $contents ;
				}
			}
		}
	}
}
