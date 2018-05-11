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

            taskcluster_client_id    => $shipit_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $shipit_scriptworker::settings::taskcluster_access_token,
            worker_group             => $shipit_scriptworker::settings::worker_group,
            worker_type              => $shipit_scriptworker::settings::worker_type,

            cot_job_type             => 'shipit',

            sign_chain_of_trust      => $shipit_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $shipit_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $shipit_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $shipit_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $shipit_scriptworker::settings::user,
        group       => $shipit_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content = $shipit_scriptworker::settings::script_config_content
    file {
        $shipit_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$shipit_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }
}
