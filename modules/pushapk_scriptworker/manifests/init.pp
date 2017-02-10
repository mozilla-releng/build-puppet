class pushapk_scriptworker {
    include pushapk_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include pushapk_scriptworker::jarsigner_init
    include pushapk_scriptworker::mime_types

    python35::virtualenv {
        $pushapk_scriptworker::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $pushapk_scriptworker::settings::user,
            group    => $pushapk_scriptworker::settings::group,
            mode     => 700,
            packages => [
                'aiohttp==1.1.2',
                'arrow==0.8.0',
                'async-timeout==1.1.0',
                'cffi==1.8.3',
                'chardet==2.3.0',
                'cryptography==1.5.2',
                'defusedxml==0.4.1',
                'frozendict==1.2',
                'google-api-python-client==1.5.3',
                'httplib2==0.9.2',
                'idna==2.1',
                'jsonschema==2.5.1',
                'mohawk==0.3.3',
                'mozapkpublisher==0.1.5',
                'multidict==2.1.2',
                'oauth2client==3.0.0',
                'pexpect==4.2.1',
                'ptyprocess==0.5.1',
                'pushapkscript==0.2.2',
                'pyasn1==0.1.9',
                'pyasn1-modules==0.0.8',
                'pycparser==2.14',
                'pyOpenSSL==16.2.0',
                'python-dateutil==2.5.3',
                'python-gnupg==0.3.9',
                'PyYAML==3.12',
                'requests==2.12.4',
                'rsa==3.4.2',
                'scriptworker==2.0.0',
                'simplejson==3.8.2',
                'six==1.10.0',
                'slugid==1.0.7',
                'taskcluster==0.3.4',
                'uritemplate==0.6',
                'virtualenv==15.0.3',
                'yarl==0.7.0',
            ];
    }

    scriptworker::instance {
        "${pushapk_scriptworker::settings::root}":
            instance_name            => $module_name,
            basedir                  => $pushapk_scriptworker::settings::root,
            work_dir                 => $pushapk_scriptworker::settings::work_dir,

            task_script              => $pushapk_scriptworker::settings::task_script,

            username                 => $pushapk_scriptworker::settings::user,
            group                    => $pushapk_scriptworker::settings::group,

            taskcluster_client_id    => $pushapk_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $pushapk_scriptworker::settings::taskcluster_access_token,
            worker_group             => $pushapk_scriptworker::settings::worker_group,
            worker_type              => $pushapk_scriptworker::settings::worker_type,

            # TODO Enable one of the next 3 lines to turn on Chain of Trust (bug 1317783)
            sign_chain_of_trust      => false,
            verify_chain_of_trust    => false,
            verify_cot_signature     => false,
            cot_job_type             => 'pushapk',

            verbose_logging          => $pushapk_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => 600,
        owner       => $pushapk_scriptworker::settings::user,
        group       => $pushapk_scriptworker::settings::group,
        show_diff   => false,
    }

    $google_play_config = $pushapk_scriptworker::settings::google_play_config

    file {
        $pushapk_scriptworker::settings::script_config:
            require     => Python35::Virtualenv[$pushapk_scriptworker::settings::root],
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;

        $google_play_config['aurora']['certificate_target_location']:
            content     => $google_play_config['aurora']['certificate'];

        $google_play_config['beta']['certificate_target_location']:
            content     => $google_play_config['beta']['certificate'];

        $google_play_config['release']['certificate_target_location']:
            content     => $google_play_config['release']['certificate'];
    }
}
