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

            taskcluster_client_id    => $bouncer_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $bouncer_scriptworker::settings::taskcluster_access_token,
            worker_group             => $bouncer_scriptworker::settings::worker_group,
            worker_type              => $bouncer_scriptworker::settings::worker_type,

            task_max_timeout         => $bouncer_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'bouncer',

            sign_chain_of_trust      => $bouncer_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $bouncer_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $bouncer_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $bouncer_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $bouncer_scriptworker::settings::user,
        group       => $bouncer_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content = $bouncer_scriptworker::settings::script_config_content
    file {
        $bouncer_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$bouncer_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }
}
