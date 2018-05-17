# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushsnap_scriptworker {
    include pushsnap_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python3
    include users::builder
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include packages::mozilla::squashfs_tools
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
        $pushsnap_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            mode            => '0700',
            packages        => file("pushsnap_scriptworker/requirements.txt");
    }

    scriptworker::instance {
        $pushsnap_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $pushsnap_scriptworker::settings::root,

            task_script              => $pushsnap_scriptworker::settings::task_script,
            task_script_config       => $pushsnap_scriptworker::settings::task_script_config,

            username                 => $users::builder::username,
            group                    => $users::builder::group,

            taskcluster_client_id    => $pushsnap_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $pushsnap_scriptworker::settings::taskcluster_access_token,
            worker_group             => $pushsnap_scriptworker::settings::worker_group,
            worker_type              => $pushsnap_scriptworker::settings::worker_type,

            task_max_timeout         => $pushsnap_scriptworker::settings::task_max_timeout,

            cot_job_type             => 'pushsnap',

            sign_chain_of_trust      => $pushsnap_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $pushsnap_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $pushsnap_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $pushsnap_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $pushsnap_scriptworker::settings::user,
        group       => $pushsnap_scriptworker::settings::group,
        show_diff   => false,
    }

    $config_content = $pushsnap_scriptworker::settings::script_config_content
    file {
        $pushsnap_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$pushsnap_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }

    $macaroons_config = $pushsnap_scriptworker::settings::macaroons_config
    case $pushsnap_scriptworker_env {
        'dep': {
            # No more files to add
        }
        'prod': {
            file {
                $macaroons_config['beta']['target_location']:
                    content     => $macaroons_config['beta']['content'];
                $macaroons_config['candidate']['target_location']:
                    content     => $macaroons_config['candidate']['content'];
                $macaroons_config['esr']['target_location']:
                    content     => $macaroons_config['esr']['content'];
            }
        }
        default: {
            fail("Invalid pushsnap_scriptworker_env given: ${pushsnap_scriptworker_env}")
        }
    }
}
