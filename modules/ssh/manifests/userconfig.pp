define ssh::userconfig($home='', $config='', $group='', $authorized_keys=[]) {
    include ssh::keys
    $username = $title

    if ($home != '') {
        $home_ = $home
    } else {
        $home_ = $operatingsystem ? {
            Darwin => "/Users/$username",
            default => "/home/$username"
        }
    }

    if ($group != '') {
        $group_ = $group
    } else {
        $group = $username
    }

    file {
        "$home_/.ssh":
            ensure => directory,
            mode => 0700,
            owner => $username,
            group => $group_;
        "$home_/.ssh/config":
            mode => 0600,
            owner => $username,
            group => $group_,
            content => $config;
        "$home_/.ssh/authorized_keys":
            mode => 0600,
            owner => $username,
            group => $group,
            content => template("ssh/ssh_authorized_keys.erb");
    }

    # delete per-user known hosts on every run
    tidy {
        "$home/.ssh/":
            matches => "known_hosts*",
            recurse => true;
    }
}
