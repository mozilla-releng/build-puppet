# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tree_scriptworker::settings {
    $root                     = '/builds/scriptworker'
    $task_script              = "${root}/bin/treescript"
    $task_script_config       = "${root}/script_config.json"
    $task_max_timeout         = 1800
    $share_base               = '/builds/hg-shared'
    $worker_group             = 'treescriptworker-v1'
    $verbose_logging          = true

    $env_config = {
        'dev' => {
            upstream_repo => 'https://hg.mozilla.org/mozilla-unified',
            taskcluster_client_id => 'project/releng/scriptworker/treescriptworker-dev',
            taskcluster_access_token => secret('treescriptworker_dev_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:releng:treescript:',
            worker_type => 'treescript-dev',
            sign_chain_of_trust => false,
            verify_chain_of_trust => false,
            verify_cot_signature => false,
            cot_product => 'firefox',
            keyset => {'trybld' => 'builder_ssh_key_try_trybld_dsa'},
            ssh_user => 'trybld'
        },
        'prod' => {
            upstream_repo => 'https://hg.mozilla.org/mozilla-unified',
            taskcluster_client_id => 'project/releng/scriptworker/treescriptworker',
            taskcluster_access_token => secret('treescriptworker_prod_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:releng:treescript:',
            worker_type => 'treescript-v1',
            sign_chain_of_trust => true,
            verify_chain_of_trust => true,
            verify_cot_signature => true,
            cot_product => 'firefox',
            keyset => {'ffxbld' => 'builder_ssh_key_prod_ffxbld_rsa'},
            ssh_user => 'ffxbld'
        },
        'tb-comm-dev' => {
            upstream_repo => 'https://hg.mozilla.org/comm-central',
            taskcluster_client_id => 'project/comm/thunderbird/releng/scriptworker/tb-treescript-comm-dev',
            taskcluster_access_token => secret('comm_thunderbird_treescriptworker_comm_dev_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:comm:thunderbird:releng:treescript:',
            worker_type => 'tb-treescript-comm-dev',
            sign_chain_of_trust => false,
            verify_chain_of_trust => true,
            verify_cot_signature => false,
            cot_product => 'thunderbird',
            keyset => {'trybld' => 'builder_ssh_key_try_trybld_dsa'},
            ssh_user => 'trybld',
        },
        'tb-comm-prod' => {
            upstream_repo => 'https://hg.mozilla.org/comm-central',
            taskcluster_client_id => 'project/comm/thunderbird/releng/scriptworker/tb-treescript-comm/prod',
            taskcluster_access_token => secret('comm_thunderbird_treescriptworker_comm_prod_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:comm:thunderbird:releng:treescript:',
            worker_type => 'tb-treescript-comm-v1',
            sign_chain_of_trust => true,
            verify_chain_of_trust => true,
            verify_cot_signature => true,
            cot_product => 'thunderbird',
            keyset => {'tbirdbld' => 'builder_ssh_key_prod_tbirdbld_dsa'},
            ssh_user => 'tbirdbld',
        },
    }
}
