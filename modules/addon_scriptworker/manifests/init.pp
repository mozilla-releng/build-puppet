# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class addon_scriptworker {
    include addon_scriptworker::settings
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
        $addon_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $addon_scriptworker::settings::user,
            group           => $addon_scriptworker::settings::group,
            mode            => 700,
            packages        => file("addon_scriptworker/requirements.txt");
    }

    scriptworker::instance {
        $addon_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $addon_scriptworker::settings::root,
            work_dir                 => $addon_scriptworker::settings::work_dir,

            task_script              => $addon_scriptworker::settings::task_script,

            username                 => $addon_scriptworker::settings::user,
            group                    => $addon_scriptworker::settings::group,

            taskcluster_client_id    => $addon_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $addon_scriptworker::settings::taskcluster_access_token,
            worker_group             => $addon_scriptworker::settings::worker_group,
            worker_type              => $addon_scriptworker::settings::worker_type,

            cot_job_type             => 'shipit',

            sign_chain_of_trust      => $addon_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $addon_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $addon_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $addon_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $addon_scriptworker::settings::user,
        group       => $addon_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content = $addon_scriptworker::settings::script_config_content
    file {
        $addon_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$addon_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }
}
