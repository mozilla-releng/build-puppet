class balrog_scriptworker::services {
    include ::config
    include balrog_scriptworker::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        "balrog_scriptworker":
            command      => "${balrog_scriptworker::settings::py35venv}/bin/scriptworker ${balrog_scriptworker::settings::root}/config.json",
            user         => $::config::builder_username,
            require      => [ File["${balrog_scriptworker::settings::root}/config.json"]],
            extra_config => template("${module_name}/supervisor_config.erb");
    }
    exec {
        "restart-scriptworker":
            command     => "/usr/bin/supervisorctl restart balrog_scriptworker",
            refreshonly => true,
            subscribe   => [Python35::Virtualenv["${balrog_scriptworker::settings::py35venv}"],
                            File["${balrog_scriptworker::settings::root}/config.json"]];
    }
}
