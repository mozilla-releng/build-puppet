# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushsnap_scriptworker::settings {
    include ::config
    include users::builder
    include python3::settings

    $root                       = $config::scriptworker_root

    $work_dir                 = "${root}/work"
    $task_script              = "${root}/bin/pushsnapscript"

    $user = $users::builder::username
    $group = $users::builder::group

    $script_config            = "${root}/script_config.json"
    $verbose_logging          = true

    case $pushsnap_scriptworker_env {
        'dep': {
            $taskcluster_client_id      = 'project/releng/scriptworker/pushsnap/dep'
            $taskcluster_access_token   = secret('pushsnap_scriptworker_taskcluster_access_token_dep')
            $worker_group               = 'dep-pushsnap'
            $worker_type                = 'dep-pushsnap'

            $sign_chain_of_trust        = false
            $verify_chain_of_trust      = true
            $verify_cot_signature       = false

            $push_to_store              = false
            $macaroons_locations = {}  # dep instance shouldn't have any credentials for Snap store
        }
        'prod': {
            $taskcluster_client_id      = 'project/releng/scriptworker/pushsnap/production'
            $taskcluster_access_token   = secret('pushsnap_scriptworker_taskcluster_access_token_prod')
            $worker_group               = 'pushsnap-v1'
            $worker_type                = 'pushsnap-v1'

            $sign_chain_of_trust        = true
            $verify_chain_of_trust      = true
            $verify_cot_signature       = true

            $push_to_store              = true
            $_snap_store_all_macaroons  = hiera_hash('pushsnap_scriptworker_snap_store_macaroons')
            $_snap_store_macaroons      = $_snap_store_all_macaroons[$fqdn]
            $macaroons_config = {
                'beta'  => {
                    content         => $_snap_store_macaroons['beta'],
                    target_location => "${root}/beta_macaroon.cfg",
                },
                'candidate'  => {
                    content         => $_snap_store_macaroons['candidate'],
                    target_location => "${root}/candidate_macaroon.cfg",
                },
                'esr'  => {
                    content         => $_snap_store_macaroons['esr'],
                    target_location => "${root}/esr_macaroon.cfg",
                },
            }

            $macaroons_locations = {
                beta      => $macaroons_config['beta']['target_location'],
                candidate => $macaroons_config['candidate']['target_location'],
                esr       => $macaroons_config['esr']['target_location'],
            }
        }
        default: {
            fail("Invalid pushsnap_scriptworker_env given: ${pushsnap_scriptworker_env}")
        }
    }

    $script_config_content      = {
        work_dir                 => $work_dir,
        push_to_store            => $push_to_store,
        macaroons_locations      => $macaroons_locations,
        verbose                  => $verbose_logging,
    }
}
