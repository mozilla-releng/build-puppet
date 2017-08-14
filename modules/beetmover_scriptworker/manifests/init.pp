# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class beetmover_scriptworker {
    include beetmover_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python35
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include tweaks::scriptworkerlogrotate

    $env_config = $beetmover_scriptworker::settings::env_config[$beetmoverworker_env]

    python35::virtualenv {
        $beetmover_scriptworker::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            mode     => '0700',
            packages => [
                  'Jinja2==2.9.6',
                  'PyYAML==3.12',
                  'MarkupSafe==1.0',
                  'aiohttp==2.1.0',
                  'arrow==0.10.0',
                  'async-timeout==1.2.1',
                  'beetmoverscript==0.5.15',
                  'boto3==1.4.4',
                  'botocore==1.5.68',
                  'certifi==2017.4.17',
                  'chardet==3.0.4',
                  'defusedxml==0.5.0',
                  'docutils==0.13.1',
                  'frozendict==1.2',
                  'idna==2.5',
                  'jmespath==0.9.3',
                  'jsonschema==2.6.0',
                  'mohawk==0.3.4',
                  'multidict==2.1.6',
                  'pexpect==4.2.1',
                  'ptyprocess==0.5.1',
                  'pyparsing==2.2.0',
                  'python-dateutil==2.6.0',
                  'python-gnupg==0.4.0',
                  'requests==2.18.1',
                  's3transfer==0.1.10',
                  'scriptworker==4.1.3',
                  'six==1.10.0',
                  'slugid==1.0.7',
                  'taskcluster==1.3.3',
                  'urllib3==1.21.1',
                  'virtualenv==15.1.0',
                  'yarl==0.10.3',
            ];
    }

    scriptworker::instance {
        $beetmover_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $beetmover_scriptworker::settings::root,

            task_script              => $beetmover_scriptworker::settings::task_script,
            task_script_config       => $beetmover_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $beetmover_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $beetmover_scriptworker::settings::taskcluster_access_token,
            worker_group             => $beetmover_scriptworker::settings::worker_group,
            worker_type              => $beetmover_scriptworker::settings::worker_type,

            task_max_timeout         => $beetmover_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'beetmover',

            verbose_logging          => $beetmover_scriptworker::settings::verbose_logging,
    }

    file {
        "${beetmover_scriptworker::settings::root}/script_config.json":
            require   => Python35::Virtualenv[$beetmover_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/script_config.json.erb"),
            show_diff => false;
    }
}
