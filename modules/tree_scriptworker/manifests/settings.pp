# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tree_scriptworker::settings {
    $root                     = '/builds/scriptworker'
    $task_script              = "${root}/bin/treescript"
    $task_script_config       = "${root}/script_config.json"
    $task_max_timeout         = 1800
    $upstream_repo            = 'https://hg.mozilla.org/mozilla-unified'
    $share_base               = '/builds/hg-shared'
    $worker_group             = 'treescriptworker-v1'
    $verbose_logging          = true

    $env_config = {
        'dev' => {
            taskcluster_client_id => 'project/releng/scriptworker/treescriptworker-dev',
            taskcluster_access_token => secret('treescriptworker_dev_taskcluster_access_token'),
            worker_type => 'treescript-dev',
            sign_chain_of_trust => false,
            verify_chain_of_trust => false,
            verify_cot_signature => false,
        },
        'prod' => {
            taskcluster_client_id => 'project/releng/scriptworker/treescriptworker',
            # No prod secret yet, this line would break puppet if not commented out
            # taskcluster_access_token => secret('treescriptworker_prod_taskcluster_access_token'),
            worker_type => 'balrogworker-v1',
            sign_chain_of_trust => true,
            verify_chain_of_trust => true,
            verify_cot_signature => true,
        }
    }
}
