class users::settings {

# calculate the proper homedir
	$home_base = $operatingsystem ? {
		Darwin => '/Users',
		default => '/home'
	}
	$home_dir = "$home_base/$config::builder_username"
}