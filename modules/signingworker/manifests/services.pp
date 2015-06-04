class signingworker::services {
    include ::config
    include signingworker::settings
    include packages::mozilla::supervisor

    supervisord::supervise {
        "signingworker":
            command      => "${signingworker::settings::root}/bin/signing-worker --admin.conf ${signingworker::settings::root}/config.json",
            user         => $::config::builder_username,
            require      => [File["${signingworker::settings::root}/config.json"],
                             File["${signingworker::settings::root}/passwords.json"],
                             Mercurial::Repo["signingworker-tools"]],
            extra_config => template("${module_name}/supervisor_config.erb");
    }
}
