class balrog_scriptworker {
    include balrog_scriptworker::services
    include balrog_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi

    $env_config = $balrog_scriptworker::settings::env_config[$balrogworker_env]

    python35::virtualenv {
        "${balrog_scriptworker::settings::root}":
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
                  "scriptworker==1.0.0b4",
                  "signingscript==0.9.0",
                  "signtool==2.0.3",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==0.3.4",
                  "virtualenv==15.0.3",
                  "yarl==0.7.0",
            ];
    }

    python::virtualenv {
        "${balrog_scriptworker::settings::root}/py27venv":
            python   => "${packages::mozilla::python27::python}",
            require  => Class["packages::mozilla::python27"],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
            packages => [
                  "balrogclient==0.0.1",
                  "boto==2.41.0",
                  "cryptography==1.2.3",
                  "enum34==1.1.2",
                  "idna==2.0",
                  "ipaddress==1.0.16",
                  "mar==1.2",
                  "pyasn1==0.1.9",
                  "requests==2.8.1",
                  "six==1.10.0",
                  "balrogscript==0.0.1",
            ];
    }

    scriptworker::instance {
        "${balrog_scriptworker::settings::root}":
            basedir                  => "${balrog_scriptworker::settings::root}",
            task_script_executable   => "${balrog_scriptworker::settings::task_script_executable}",
            task_script              => "${balrog_scriptworker::settings::task_script}",
            task_script_config       => "${balrog_scriptworker::settings::task_script_config}",
            task_max_timeout         => $balrog_scriptworker::settings::task_max_timeout,
            username                 => "${users::builder::username}",
            group                    => "${users::builder::group}",
            worker_group             => "$env_config[worker_group]",
            worker_type              => "$env_config[worker_type]",
            cot_job_type             => "balrog",
            verbose_logging          => "$env_config[verbose_logging]",
            taskcluster_client_id    => "$env_config[taskcluster_client_id]",
            taskcluster_access_token => "$env_config[taskcluster_access_token]",
    }

    mercurial::repo {
        "tools":
            hg_repo => "${balrog_scriptworker::settings::tools_repo}",
            dst_dir => "${balrog_scriptworker::settings::root}/tools",
            user    => "${users::builder::username}",
            branch  => "${balrog_scriptworker::settings::tools_branch}",
            require => [
                Class["packages::mozilla::py27_mercurial"],
                Python35::Virtualenv["${balrog_scriptworker::settings::root}"],
            ];
    }

    file {
        "${balrog_scriptworker::settings::root}/script_config.json":
            require     => Python35::Virtualenv["${balrog_scriptworker::settings::root}"],
            mode        => 600,
            owner       => "${users::builder::username}",
            group       => "${users::builder::group}",
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;
    }
}
