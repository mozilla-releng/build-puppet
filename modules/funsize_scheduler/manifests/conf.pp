class funsize_scheduler::conf {
    include ::config
    include funsize_scheduler::settings
    include dirs::builds
    include users::builder

    file {
        "${funsize_scheduler::settings::root}/config.yml":
            require     => Python::Virtualenv["${funsize_scheduler::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.yml.erb"),
            show_diff   => false;
        "${funsize_scheduler::settings::root}/id_rsa":
            require     => Python::Virtualenv["${funsize_scheduler::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => secret("funsize_signing_pvt_key"),
            show_diff   => false;
    }
}
