class sudoers::settings {
    include ::shared
    include users::root
    $group = $users::root::group
    $owner = $users::root::username
    $mode = "440"
     case $operatingsystem {
     	CentOS : {
     		$rebootpath = "/usr/bin/reboot"
     	}
     	Darwin : {
     		$rebootpath = "/sbin/reboot"
     	}
     }
}
    
