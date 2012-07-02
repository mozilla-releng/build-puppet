define osxutils::systemsetup ($option = $title,$setting = '') {
	
	$cmd = "/usr/sbin/systemsetup"
	
	if ($option != undef) and ($setting != undef) {
		exec {
			"osx_systemsetup -set$title $setting" :
				command => "${cmd} -set$title $setting",
				unless =>
				"$cmd -get$title | awk -F \": \" \'{print \$2}\' | grep -i ${setting}",
		}
	}
}
