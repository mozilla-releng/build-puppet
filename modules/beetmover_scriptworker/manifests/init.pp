class beetmover_scriptworker {
    include beetmover_scriptworker::services
    include beetmover_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi

    $env_config = $beetmover_scriptworker::settings::env_config[$beetmoverworker_env]

    python35::virtualenv {
        "${beetmover_scriptworker::settings::root}":
            python3  => "${packages::mozilla::python35::python3}",
            require  => Class["packages::mozilla::python35"],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
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
                  "scriptworker==1.0.0b8",
                  "signtool==2.0.3",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==0.3.4",
                  "virtualenv==15.0.3",
                  "boto3==1.4.1",
                  "botocore==1.4.63",
                  "jmespath==0.9.0",
                  "Jinja2==2.8",
                  "beetmoverscript==0.1.4",
                  "MarkupSafe==0.23",
                  "s3transfer==0.1.8",
                  "docutils==0.12",
                  "yarl==0.7.0",
            ];
    }

    scriptworker::instance {
        "${beetmover_scriptworker::settings::root}":
            basedir                  => "${beetmover_scriptworker::settings::root}",
            task_script_executable   => "${beetmover_scriptworker::settings::task_script_executable}",
            task_script              => "${beetmover_scriptworker::settings::task_script}",
            task_script_config       => "${beetmover_scriptworker::settings::task_script_config}",
            task_max_timeout         => $beetmover_scriptworker::settings::task_max_timeout,
            username                 => "${users::builder::username}",
            group                    => "${users::builder::group}",
            worker_group             => "${beetmover_scriptworker::settings::worker_group}",
            worker_type              => "${beetmover_scriptworker::settings::worker_type}",
            cot_job_type             => "beetmover",
            verbose_logging          => $beetmover_scriptworker::settings::verbose_logging,
            taskcluster_client_id    => "${beetmover_scriptworker::settings::taskcluster_client_id}",
            taskcluster_access_token => "${beetmover_scriptworker::settings::taskcluster_access_token}",
    }

    file {
        "${beetmover_scriptworker::settings::root}/script_config.json":
            require     => Python35::Virtualenv["${beetmover_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;
    }
}
