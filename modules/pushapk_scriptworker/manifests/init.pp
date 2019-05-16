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

    $root = $config::scriptworker_root

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
            github_oauth_token       => $pushapk_scriptworker::settings::github_oauth_token,

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

    $google_play_accounts = $pushapk_scriptworker::settings::google_play_accounts
    $config_content = $pushapk_scriptworker::settings::script_config_content
    file {
        $pushapk_scriptworker::settings::script_config:
            require => Python3::Virtualenv[$pushapk_scriptworker::settings::root],
            content => inline_template("<%- require 'json' -%><%= JSON.pretty_generate(@config_content) %>");
    }

    case $pushapk_scriptworker_env {
        'dep': {
            file {
                "${root}/dep.p12":
                    content => 'dummy';
            }
        }
        'prod': {
            file {
                "${root}/aurora.p12":
                    content => $google_play_accounts['aurora']['certificate'];
                "${root}/beta.p12":
                    content => $google_play_accounts['beta']['certificate'];
                "${root}/release.p12":
                    content => $google_play_accounts['release']['certificate'];
            }
        }
        'mobile-dep': {
            file {
                "${root}/fenix.p12":
                    content => 'dummy';
                "${root}/focus.p12":
                    content => 'dummy';
                "${root}/reference_browser.p12":
                    content => 'dummy';
            }
        }
        'mobile-prod': {
            file {
                "${root}/fenix_nightly.p12":
                    content => $google_play_accounts['fenix-nightly']['certificate'];
                "${root}/fenix_beta.p12":
                    content => $google_play_accounts['fenix-beta']['certificate'];
                "${root}/focus.p12":
                    content => $google_play_accounts['focus']['certificate'];
                "${root}/reference_browser.p12":
                    content => $google_play_accounts['reference_browser']['certificate'];
            }
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }
}
