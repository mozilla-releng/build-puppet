# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker {
    include pushapk_scriptworker::settings
    include dirs::builds
    include packages::mozilla::python3
    include tweaks::swap_on_instance_storage
    include packages::gcc
    include packages::make
    include packages::libffi
    include pushapk_scriptworker::jarsigner_init
    include pushapk_scriptworker::mime_types
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
        $pushapk_scriptworker::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python3'],
            user            => $pushapk_scriptworker::settings::user,
            group           => $pushapk_scriptworker::settings::group,
            mode            => 700,
            packages        => file("pushapk_scriptworker/requirements.txt");
    }

    scriptworker::instance {
        $pushapk_scriptworker::settings::root:
            instance_name            => $module_name,
            basedir                  => $pushapk_scriptworker::settings::root,
            work_dir                 => $pushapk_scriptworker::settings::work_dir,

            task_script              => $pushapk_scriptworker::settings::task_script,

            username                 => $pushapk_scriptworker::settings::user,
            group                    => $pushapk_scriptworker::settings::group,

            taskcluster_client_id    => $pushapk_scriptworker::settings::taskcluster_client_id,
            taskcluster_access_token => $pushapk_scriptworker::settings::taskcluster_access_token,
            worker_group             => $pushapk_scriptworker::settings::worker_group,
            worker_type              => $pushapk_scriptworker::settings::worker_type,

            cot_job_type             => 'pushapk',
            cot_product              => $pushapk_scriptworker::settings::cot_product,

            sign_chain_of_trust      => $pushapk_scriptworker::settings::sign_chain_of_trust,
            verify_chain_of_trust    => $pushapk_scriptworker::settings::verify_chain_of_trust,
            verify_cot_signature     => $pushapk_scriptworker::settings::verify_cot_signature,

            verbose_logging          => $pushapk_scriptworker::settings::verbose_logging,
    }

    File {
        ensure      => present,
        mode        => '0600',
        owner       => $pushapk_scriptworker::settings::user,
        group       => $pushapk_scriptworker::settings::group,
        show_diff   => false,
    }

    $google_play_config = $pushapk_scriptworker::settings::google_play_config
    $config_content = $pushapk_scriptworker::settings::script_config_content
    file {
        $pushapk_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$pushapk_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }

    case $pushapk_scriptworker_env {
        'dep': {
            file {
                $google_play_config['dep']['certificate_target_location']:
                    content     => $google_play_config['dep']['certificate'];
            }
        }
        'prod': {
            file {
                $google_play_config['aurora']['certificate_target_location']:
                    content     => $google_play_config['aurora']['certificate'];
                $google_play_config['beta']['certificate_target_location']:
                    content     => $google_play_config['beta']['certificate'];
                $google_play_config['release']['certificate_target_location']:
                    content     => $google_play_config['release']['certificate'];
            }
        }
        'mobile-prod': {
            file {
                $google_play_config['focus']['certificate_target_location']:
                    content     => $google_play_config['focus']['certificate'];
            }
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }
}
