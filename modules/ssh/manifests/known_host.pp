define ssh::known_host($home = '', $hostkey) {
    
    if ($home == '') {
        include users::builder
        $home_dir = $users::builder::home
    } else {
        $home_dir = $home
    }

    concat::fragment {
        "$title":
            content => "$hostkey\n",
            order => 10,
            target => "$home_dir/.ssh/known_hosts";
    }
}
