class pushapkworker::services {
    include ::config
    include pushapkworker::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        'pushapkworker':
            command      => "${pushapkworker::settings::root}/bin/scriptworker ${config::pushapk_scriptworker_worker_config}",
            user         => $::config::builder_username,
            require      => [ File[$config::pushapk_scriptworker_worker_config],
                              File[$config::pushapk_scriptworker_script_config]],
            extra_config => template("${module_name}/supervisor_config.erb");
    }
    exec {
        'restart-pushapkworker':
            command     => '/usr/bin/supervisorctl restart pushapkworker',
            refreshonly => true,
            subscribe   => [Python35::Virtualenv[$pushapkworker::settings::root],
                            File[$config::pushapk_scriptworker_worker_config],
                            File[$config::pushapk_scriptworker_script_config]];
    }
}
