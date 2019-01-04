# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class shipit_scriptworker {
    include shipit_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python3
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include tweaks::scriptworkerlogrotate

    $env_config = $shipit_scriptworker::settings::env_config[$shipit_scriptworker_env]

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop ${module_name}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python3'];
    }

    python3::virtualenv {
        $shipit_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $shipit_scriptworker::settings::user,
            group           => $shipit_scriptworker::settings::group,
            mode            => 700,
            packages        => file("shipit_scriptworker/requirements.txt");
    }

    scriptworker::instance {
        $shipit_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $shipit_scriptworker::settings::root,
            work_dir                 => $shipit_scriptworker::settings::work_dir,

            task_script              => $shipit_scriptworker::settings::task_script,

            username                 => $shipit_scriptworker::settings::user,
            group                    => $shipit_scriptworker::settings::group,

            taskcluster_client_id    => $env_config["taskcluster_client_id"],
            taskcluster_access_token => $env_config["taskcluster_access_token"],
            worker_group             => $env_config['worker_group'],
            worker_type              => $env_config["worker_type"],

            cot_job_type             => 'shipit',
            cot_product              => $env_config['cot_product'],

            sign_chain_of_trust      => $env_config["sign_chain_of_trust"],
            verify_chain_of_trust    => $env_config["verify_chain_of_trust"],
            verify_cot_signature     => $env_config["verify_cot_signature"],

            verbose_logging          => $shipit_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $shipit_scriptworker::settings::user,
        group       => $shipit_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content      = {
        work_dir           => $shipit_scriptworker::settings::work_dir,
        verbose            => $shipit_scriptworker::settings::verbose_logging,
        ship_it_instances  => $env_config['ship_it_instances'],
        taskcluster_scope_prefix => $env_config['taskcluster_scope_prefix'],
    }
    file {
        $shipit_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$shipit_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }
}
