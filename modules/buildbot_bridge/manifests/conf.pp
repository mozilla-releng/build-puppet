class buildbot_bridge::conf {
    include ::config
    include buildbot_bridge::settings
    include dirs::builds
    include users::builder

    file {
        "${buildbot_bridge::settings::root}/config.json":
            require     => Python::Virtualenv["${buildbot_bridge::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.json.erb"),
            show_diff   => false;
    }
}
