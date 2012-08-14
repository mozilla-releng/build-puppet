class ssh::config {
    include users::root
    include ssh::settings
    include ssh::service

    file {
        $ssh::settings::ssh_config:
            owner => $users::root::username,
            group => $users::root::group,
            mode => 0644,
            content => template("${module_name}/ssh_config.erb");
        $ssh::settings::sshd_config:
            owner => $::users::root::username,
            group => $::users::root::group,
            mode => 0644,
            notify => Class['ssh::service'], # restart daemon if necessary
            content => template("${module_name}/sshd_config.erb");
    }
}
