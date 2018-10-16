# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class bouncer_scriptworker {
    include bouncer_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python3
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include tweaks::scriptworkerlogrotate
    include tweaks::scriptworkerlogrotate

    $env_config = $bouncer_scriptworker::settings::env_config[$bouncer_scriptworker_env]

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python3'];
    }

    python3::virtualenv {
        $bouncer_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            mode            => '0700',
            packages        => file("bouncer_scriptworker/requirements.txt");
    }

    scriptworker::instance {
        $bouncer_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $bouncer_scriptworker::settings::root,

            task_script              => $bouncer_scriptworker::settings::task_script,
            task_script_config       => $bouncer_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $env_config['taskcluster_client_id'],
            taskcluster_access_token => $env_config['taskcluster_access_token'],
            worker_group             => $env_config['worker_group'],
            worker_type              => $env_config['worker_type'],

            task_max_timeout         => $bouncer_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'bouncer',
            cot_product              => $env_config['cot_product'],

            sign_chain_of_trust      => $env_config['sign_chain_of_trust'],
            verify_chain_of_trust    => $env_config['verify_chain_of_trust'],
            verify_cot_signature     => $env_config['verify_cot_signature'],

            verbose_logging          => $bouncer_scriptworker::settings::verbose_logging,
    }

    $bouncer_instances = $env_config['bouncer_instances']
    file {
        $bouncer_scriptworker::settings::script_config:
            require   => Python3::Virtualenv[$bouncer_scriptworker::settings::root],
            mode      => '0600',
            owner     => $bouncer_scriptworker::settings::user,
            group     => $bouncer_scriptworker::settings::group,
            content   => template("${module_name}/script_config.json.erb"),
            show_diff => false;
    }
}
