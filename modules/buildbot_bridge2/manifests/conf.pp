class buildbot_bridge2::conf {
    include ::config
    include buildbot_bridge2::settings
    include dirs::builds
    include users::builder

    $env_config = $::buildbot_bridge2::settings::env_config

    file {
        "${buildbot_bridge2::settings::root}/config.yml":
            require     => Python35::Virtualenv["${buildbot_bridge2::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.yml.erb"),
            show_diff   => false;
    }
}
