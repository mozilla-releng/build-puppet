class signing_scriptworker {
    include ::config
    include signing_scriptworker::services
    include signing_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::signer
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make

    # because puppet barfs whenever I try to put it in settings.pp
    $verbose_logging = true

    python35::virtualenv {
        "${signing_scriptworker::settings::root}":
            python3  => "${packages::mozilla::python35::python3}",
            require  => Class["packages::mozilla::python35"],
            user     => "${users::signer::username}",
            group    => "${users::signer::group}",
            mode     => 700,
            packages => [
                  "aiohttp==1.1.2",
                  "arrow==0.8.0",
                  "async-timeout==1.1.0",
                  "chardet==2.3.0",
                  "defusedxml==0.4.1",
                  "ecdsa==0.13",
                  "frozendict==1.2",
                  "future==0.16.0",
                  "jsonschema==2.5.1",
                  "mohawk==0.3.3",
                  "multidict==2.1.2",
                  "pefile==2016.7.26",
                  "pexpect==4.2.1",
                  "ptyprocess==0.5.1",
                  "pycrypto==2.6.1",
                  "python-dateutil==2.6.0",
                  "python-gnupg==0.3.9",
                  "python-jose==1.3.2",
                  "PyYAML==3.12",
                  "requests==2.11.1",
                  "scriptworker==1.0.0b2",
                  "signingscript==0.8.2",
                  "signtool==2.0.3",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==0.3.4",
                  "virtualenv==15.0.3",
                  "yarl==0.7.0",
            ];
    }

    scriptworker::instance {
        "${signing_scriptworker::settings::root}":
            basedir                  => "${signing_scriptworker::settings::root}",
            task_script_executable   => "${signing_scriptworker::settings::task_script_executable}",
            task_script              => "${signing_scriptworker::settings::task_script}",
            task_script_config       => "${signing_scriptworker::settings::task_script_config}",
            task_max_timeout         => $signing_scriptworker::settings::task_max_timeout,
            username                 => "${users::signer::username}",
            group                    => "${users::signer::group}",
            worker_group             => "${signing_scriptworker::settings::worker_group}",
            worker_type              => "${signing_scriptworker::settings::worker_type}",
            cot_job_type             => "signing",
            verbose_logging          => $verbose_logging,
            taskcluster_client_id    => secret("signing_scriptworker_taskcluster_client_id"),
            taskcluster_access_token => secret("signing_scriptworker_taskcluster_access_token");
    }

    file {
        "${signing_scriptworker::settings::root}/script_config.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;
        "${signing_scriptworker::settings::root}/passwords.json":
            require     => Python35::Virtualenv["${signing_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            content     => template("${module_name}/passwords.json.erb"),
            show_diff => false;
    }
}
