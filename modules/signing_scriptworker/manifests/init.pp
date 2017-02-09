class signing_scriptworker {
    include ::config
    include signing_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::signer
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make

    # because puppet barfs whenever I try to put it in settings.pp
    $verbose_logging = true
    $build_tools_version = '23.0.3'
    # See value defined in packages::mozilla::android_sdk
    $zipalign_location = "/tools/android-sdk/build-tools/$build_tools_version/zipalign"

    python35::virtualenv {
        "${signing_scriptworker::settings::root}":
            python3  => "${packages::mozilla::python35::python3}",
            require  => Class["packages::mozilla::python35"],
            user     => "${users::signer::username}",
            group    => "${users::signer::group}",
            mode     => 700,
            packages => [
                  "PyYAML==3.12",
                  "aiohttp==1.2.0",
                  "appdirs==1.4.0",
                  "arrow==0.10.0",
                  "async-timeout==1.1.0",
                  "chardet==2.3.0",
                  "defusedxml==0.4.1",
                  "ecdsa==0.13",
                  "frozendict==1.2",
                  "future==0.16.0",
                  "jsonschema==2.5.1",
                  "mohawk==0.3.4",
                  "multidict==2.1.4",
                  "packaging==16.8",
                  "pefile==2016.7.26",
                  "pexpect==4.2.1",
                  "ptyprocess==0.5.1",
                  "pycrypto==2.6.1",
                  "pyparsing==2.1.10",
                  "python-dateutil==2.6.0",
                  "python-gnupg==0.4.0",
                  "python-jose==1.3.2",
                  "requests==2.13.0",
                  "scriptworker==2.1.1",
                  "signingscript==0.10.1",
                  "signtool==2.0.3",
                  "six==1.10.0",
                  "slugid==1.0.7",
                  "taskcluster==1.0.2",
                  "virtualenv==15.1.0",
                  "yarl==0.8.1",
            ];
    }

    scriptworker::instance {
        "${signing_scriptworker::settings::root}":
            instance_name            => $module_name,
            basedir                  => $signing_scriptworker::settings::root,

            task_script              => $signing_scriptworker::settings::task_script,
            task_script_config       => $signing_scriptworker::settings::task_script_config,

            username                 => $users::signer::username,
            group                    => $users::signer::group,

            taskcluster_client_id    => secret("signing_scriptworker_taskcluster_client_id"),
            taskcluster_access_token => secret("signing_scriptworker_taskcluster_access_token"),
            worker_group             => $signing_scriptworker::settings::worker_group,
            worker_type              => $signing_scriptworker::settings::worker_type,
            task_max_timeout         => 1800,

            cot_job_type             => "signing",

            verbose_logging          => $verbose_logging,
    }

    nrpe::custom {
        "signingworker.cfg":
            content => template("${module_name}/nagios.cfg.erb");
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
        "${signing_scriptworker::settings::root}/file_age_check_optionals.txt":
            mode        => 640,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            source      => "puppet:///modules/signing_scriptworker/file_age_check_optionals.txt",
            show_diff   => true;
        "${signing_scriptworker::settings::root}/file_age_check_required.txt":
            mode        => 640,
            owner       => "${users::signer::username}",
            group       => "${users::signer::group}",
            source      => "puppet:///modules/signing_scriptworker/file_age_check_required.txt",
            show_diff   => true;
    }

    packages::mozilla::android_sdk {
      $build_tools_version:
        username          => $users::signer::username,
        group             => $users::signer::group,
        zipalign_location => $zipalign_location;
    }
}
