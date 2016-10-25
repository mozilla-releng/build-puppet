class beetmover_scriptworker::services {
    include ::config
    include beetmover_scriptworker::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        "beetmover_scriptworker":
            command      => "${beetmover_scriptworker::settings::root}/bin/scriptworker ${beetmover_scriptworker::settings::root}/config.json",
            user         => $::config::builder_username,
            require      => [ File["${beetmover_scriptworker::settings::root}/config.json"]],
            extra_config => template("${module_name}/supervisor_config.erb");
    }
    exec {
        "restart-beetmoverworker":
            command     => "/usr/bin/supervisorctl restart beetmover_scriptworker",
            refreshonly => true,
            subscribe   => [Python35::Virtualenv["${beetmover_scriptworker::settings::root}"],
                            File["${beetmover_scriptworker::settings::root}/config.json"]];
    }
}
