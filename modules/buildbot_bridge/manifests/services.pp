class buildbot_bridge::services {
    include ::config
    include buildbot_bridge::conf
    include buildbot_bridge::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        "buildbot_bridge_bblistener":
            command      => "${buildbot_bridge::settings::root}/bin/buildbot-bridge -c ${buildbot_bridge::settings::root}/config.json bblistener",
            user         => $::config::builder_username,
            require      => [File["${buildbot_bridge::settings::root}/config.json"],
                            Python::Virtualenv["${buildbot_bridge::settings::root}"]],
            extra_config => template("${module_name}/bblistener_supervisor_config.erb");

        "buildbot_bridge_tclistener":
            command      => "${buildbot_bridge::settings::root}/bin/buildbot-bridge -c ${buildbot_bridge::settings::root}/config.json tclistener",
            user         => $::config::builder_username,
            require      => [File["${buildbot_bridge::settings::root}/config.json"],
                            Python::Virtualenv["${buildbot_bridge::settings::root}"]],
            extra_config => template("${module_name}/tclistener_supervisor_config.erb");

        "buildbot_bridge_reflector":
            command      => "${buildbot_bridge::settings::root}/bin/buildbot-bridge -c ${buildbot_bridge::settings::root}/config.json reflector",
            user         => $::config::builder_username,
            require      => [File["${buildbot_bridge::settings::root}/config.json"],
                            Python::Virtualenv["${buildbot_bridge::settings::root}"]],
            extra_config => template("${module_name}/reflector_supervisor_config.erb");
    }

#    exec {
#        "restart-buildbot-bridge":
#            command     => "/usr/bin/supervisorctl restart buildbot_bridge_bblistener buildbot_bridge_tclistener buildbot_bridge_reflector",
#            refreshonly => true,
#            subscribe   => [Python::Virtualenv["${buildbot_bridge::settings::root}"],
#                            File["${buildbot_bridge::settings::root}/config.json"]];
#    }
}
