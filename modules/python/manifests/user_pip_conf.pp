define python::user_pip_conf($homedir='') {
    include config

    $user = $title
    $homedir_ = $homedir ? {
        '' => "/home/$user",
        default => $homedir,
    }

    # for the template
    $repo_servers = $config::repo_servers
    $yum_server = $config::yum_server

    file {
        "$homedir_/.pip":
            ensure => directory,
            owner => $user,
            group => $user,
            mode => 0755;
        "$homedir_/.pip/pip.conf":
            content => template("python/user-pip-conf.erb"),
            owner => $user,
            group => $user,
            mode => 0644;
    }
}
