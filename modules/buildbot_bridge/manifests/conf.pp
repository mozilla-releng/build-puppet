class buildbot_bridge::conf {
    include ::config
    include buildbot_bridge::settings
    include dirs::builds
    include users::builder
    include packages::logrotate

    $env_config = $::buildbot_bridge::settings::env_config

    file {
        "${buildbot_bridge::settings::root}/config.json":
            require     => Python::Virtualenv["${buildbot_bridge::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/config.json.erb"),
            show_diff   => false;
        "/etc/logrotate.d/buildbotbridge":
            content     => template("${module_name}/buildbotbridge.logrotate.erb"),
            require     => Class['packages::logrotate'];
    }
}
