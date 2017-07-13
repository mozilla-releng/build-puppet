# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class transparency_scriptworker {
    include transparency_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include packages::mozilla::lego
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi

    $env_config = $transparency_scriptworker::settings::env_config[$transparencyworker_env]

    python35::virtualenv {
        $transparency_scriptworker::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            mode     => '0700',
            packages => [
                  'aiohttp==2.1.0',
                  'arrow==0.10.0',
                  'async-timeout==1.2.1',
                  'certifi==2017.4.17',
                  'chardet==3.0.4',
                  'defusedxml==0.5.0',
                  'frozendict==1.2',
                  'idna==2.5',
                  'jsonschema==2.6.0',
                  'mohawk==0.3.4',
                  'multidict==2.1.6',
                  'pexpect==4.2.1',
                  'ptyprocess==0.5.1',
                  'python-dateutil==2.6.0',
                  'python-gnupg==0.4.0',
                  'PyYAML==3.12',
                  'redo==1.6',
                  'requests==2.18.1',
                  'scriptworker==4.1.3',
                  'six==1.10.0',
                  'slugid==1.0.7',
                  'taskcluster==1.3.3',
                  'transparencyscript==0.0.4',
                  'urllib3==1.21.1',
                  'virtualenv==15.1.0',
                  'yarl==0.10.3',
            ];
    }

    scriptworker::instance {
        $transparency_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $transparency_scriptworker::settings::root,

            task_script              => $transparency_scriptworker::settings::task_script,
            task_script_config       => $transparency_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $env_config["taskcluster_client_id"],
            taskcluster_access_token => $env_config["taskcluster_access_token"],
            worker_id                => $env_config["worker_id"],
            worker_group             => $env_config["worker_group"],
            worker_type              => $env_config["worker_type"],

            task_max_timeout         => $transparency_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'transparency',

            sign_chain_of_trust      => $env_config["sign_chain_of_trust"],
            verify_chain_of_trust    => $env_config["verify_chain_of_trust"],
            verify_cot_signature     => $env_config["verify_cot_signature"],

            verbose_logging          => $transparency_scriptworker::settings::verbose_logging,
    }

    file {
        "${transparency_scriptworker::settings::root}/script_config.json":
            require   => Python35::Virtualenv[$transparency_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/script_config.json.erb");
    }

    file {
        "${transparency_scriptworker::settings::root}/passwords.json":
            require   => Python35::Virtualenv[$transparency_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/passwords.json.erb"),
            show_diff => false;
    }
}
