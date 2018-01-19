# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class balrog_scriptworker {
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
    include tweaks::scriptworkerlogrotate

    $env_config = $balrog_scriptworker::settings::env_config[$balrogworker_env]

    python35::virtualenv {
        $balrog_scriptworker::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            mode     => '0700',
            packages => [
                  'PyYAML==3.12',
                  'aiohttp==2.3.9',
                  'arrow==0.12.1',
                  'async_timeout==1.4.0',
                  'certifi==2018.1.18',
                  'chardet==3.0.4',
                  'defusedxml==0.5.0',
                  'dictdiffer==0.7.0',
                  'frozendict==1.2',
                  'idna==2.6',
                  'json-e==2.5.0',
                  'jsonschema==2.6.0',
                  'mohawk==0.3.4',
                  'multidict==4.0.0',
                  'pexpect==4.3.1',
                  'ptyprocess==0.5.2',
                  'python-dateutil==2.6.1',
                  'python-gnupg==0.4.1',
                  'requests==2.18.4',
                  'scriptworker==8.0.0',
                  'six==1.10.0',
                  'slugid==1.0.7',
                  'taskcluster==2.1.3',
                  'urllib3==1.22',
                  'virtualenv==15.1.0',
                  'yarl==1.0.0',
            ];
    }

    python27::virtualenv {
        "${balrog_scriptworker::settings::root}/py27venv":
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            packages => [
                  'appdirs==1.4.3',
                  'arrow==0.10.0',
                  'asn1crypto==0.22.0',
                  'balrogclient==0.0.4',
                  'balrogscript==1.1.0',
                  'cffi==1.10.0',
                  'click==6.7',
                  'construct==2.8.11',
                  'cryptography==1.8.1',
                  'enum34==1.1.6',
                  'functools32==3.2.3-2',
                  'idna==2.5',
                  'ipaddress==1.0.18',
                  'jsonschema==2.6.0',
                  'mar==2.0',
                  'packaging==16.8',
                  'pyasn1==0.2.3',
                  'pycparser==2.17',
                  'pyparsing==2.2.0',
                  'python-dateutil==2.6.0',
                  'requests==2.13.0',
                  'six==1.10.0',
            ];
    }

    scriptworker::instance {
        $balrog_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $balrog_scriptworker::settings::root,

            task_script_executable   => $balrog_scriptworker::settings::task_script_executable,
            task_script              => $balrog_scriptworker::settings::task_script,
            task_script_config       => $balrog_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $env_config["taskcluster_client_id"],
            taskcluster_access_token => $env_config["taskcluster_access_token"],
            worker_group             => $balrog_scriptworker::settings::worker_group,
            worker_type              => $env_config["worker_type"],

            task_max_timeout         => $balrog_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'balrog',

            sign_chain_of_trust      => $env_config["sign_chain_of_trust"],
            verify_chain_of_trust    => $env_config["verify_chain_of_trust"],
            verify_cot_signature     => $env_config["verify_cot_signature"],

            verbose_logging          => $balrog_scriptworker::settings::verbose_logging,
    }

    mercurial::repo {
        'tools':
            hg_repo => $env_config["tools_repo"],
            dst_dir => "${balrog_scriptworker::settings::root}/tools",
            user    => $users::builder::username,
            branch  => $balrog_scriptworker::settings::tools_branch,
            require => [
                Class['packages::mozilla::py27_mercurial'],
                Python35::Virtualenv[$balrog_scriptworker::settings::root],
            ];
    }

    file {
        "${balrog_scriptworker::settings::root}/script_config.json":
            require   => Python35::Virtualenv[$balrog_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/script_config.json.erb"),
            show_diff => false;
    }
}
