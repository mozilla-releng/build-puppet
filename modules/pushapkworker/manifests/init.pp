class pushapkworker {
    include ::config
    include pushapkworker::services
    include pushapkworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include pushapkworker::jarsigner_init
    include pushapkworker::mime_types

    $env_config = $config::pushapk_scriptworker_env_config[$pushapkworker_env]
    $google_play_config = $env_config['google_play_config']

    python35::virtualenv {
        $pushapkworker::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            mode     => 700,
            packages => [
                'aiohttp==1.0.2',
                'arrow==0.8.0',
                'async-timeout==1.0.0',
                'cffi==1.8.3',
                'chardet==2.3.0',
                'cryptography==1.5.2',
                'defusedxml==0.4.1',
                'frozendict==1.0',
                'google-api-python-client==1.5.3',
                'httplib2==0.9.2',
                'idna==2.1',
                'jsonschema==2.5.1',
                'mohawk==0.3.3',
                'mozapkpublisher==0.1.3',
                'multidict==2.1.2',
                'oauth2client==3.0.0',
                'pexpect==4.2.1',
                'ptyprocess==0.5.1',
                'pushapkscript==0.1.4',
                'pyasn1==0.1.9',
                'pyasn1-modules==0.0.8',
                'pycparser==2.14',
                'pyOpenSSL==16.1.0',
                'python-dateutil==2.5.3',
                'python-gnupg==0.3.9',
                'requests==2.11.1',
                'rsa==3.4.2',
                'scriptworker==0.7.2',
                'simplejson==3.8.2',
                'six==1.10.0',
                'slugid==1.0.7',
                'taskcluster==0.3.4',
                'uritemplate==0.6',
                'virtualenv==15.0.3'
            ];
    }

    nrpe::custom {
        'pushapkworker.cfg':
            content => template("${module_name}/nagios.cfg.erb");
    }

    File {
        ensure      => present,
        mode        => 600,
        owner       => $users::builder::username,
        group       => $users::builder::group,
        show_diff   => false,
    }

    file {
        $config::pushapk_scriptworker_script_config:
            require     => Python35::Virtualenv[$pushapkworker::settings::root],
            content     => template("${module_name}/script_config.json.erb"),
            show_diff   => true;

        $config::pushapk_scriptworker_worker_config:
            require     => Python35::Virtualenv[$pushapkworker::settings::root],
            content     => template("${module_name}/config.json.erb");

        $google_play_config['aurora']['certificate_target_location']:
            content     => $google_play_config['aurora']['certificate'];

        $google_play_config['beta']['certificate_target_location']:
            content     => $google_play_config['beta']['certificate'];

        $google_play_config['release']['certificate_target_location']:
            content     => $google_play_config['release']['certificate'];

        # TODO Remove the following statement line once bug 1321513 reaches production
        $config::pushapk_scriptworker_old_root:
            ensure      => absent,
            force       => true;  # Needed to delete a folder
    }
}
