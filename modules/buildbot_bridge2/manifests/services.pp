class buildbot_bridge2::services {
    include ::config
    include buildbot_bridge2::conf
    include buildbot_bridge2::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        "buildbot_bridge2_reflector":
            command      => "${buildbot_bridge2::settings::root}/bin/reflector --config ${buildbot_bridge2::settings::root}/config.yml",
            user         => $::config::builder_username,
            require      => [File["${buildbot_bridge2::settings::root}/config.yml"],
                            Python35::Virtualenv["${buildbot_bridge2::settings::root}"]],
            extra_config => template("${module_name}/reflector_supervisor_config.erb");
    }

    exec {
        "restart-buildbot-bridge2":
            command     => '/usr/bin/supervisorctl restart buildbot_bridge2_reflector',
            refreshonly => true,
            subscribe   => [Python35::Virtualenv["${buildbot_bridge2::settings::root}"],
                            File["${buildbot_bridge2::settings::root}/config.yml"]];
    }
}
