# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tree_scriptworker {
    include tree_scriptworker::settings
    include dirs::builds
    include dirs::builds::hg_shared
    include packages::mozilla::python3
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include tweaks::scriptworkerlogrotate

    $env_config = $tree_scriptworker::settings::env_config[$treescriptworker_env]

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python3'];
    }

    python3::virtualenv {
        $tree_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            mode            => '0700',
            packages        => file("tree_scriptworker/requirements.txt");
    }

    scriptworker::instance {
        $tree_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $tree_scriptworker::settings::root,

            task_script_executable   => $tree_scriptworker::settings::task_script_executable,
            task_script              => $tree_scriptworker::settings::task_script,
            task_script_config       => $tree_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $env_config["taskcluster_client_id"],
            taskcluster_access_token => $env_config["taskcluster_access_token"],
            worker_group             => $tree_scriptworker::settings::worker_group,
            worker_type              => $env_config["worker_type"],

            task_max_timeout         => $tree_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'scriptworker',

            sign_chain_of_trust      => $env_config["sign_chain_of_trust"],
            verify_chain_of_trust    => $env_config["verify_chain_of_trust"],
            verify_cot_signature     => $env_config["verify_cot_signature"],

            verbose_logging          => $tree_scriptworker::settings::verbose_logging,
    }

    file {
        "${tree_scriptworker::settings::root}/script_config.json":
            require   => Python3::Virtualenv[$tree_scriptworker::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template("${module_name}/script_config.json.erb"),
            show_diff => false;
    }

    $key_names = keys($env_config["keyset"])
    slave_secrets::ssh_key {
        $key_names:
            slave_keyset => $env_config["keyset"];
    }
}
