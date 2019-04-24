# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class balrog_scriptworker::settings {
    $root                     = '/builds/scriptworker'
    $task_script_executable   = "${root}/py27venv/bin/python"
    $task_script              = "${root}/py27venv/bin/balrogscript"
    $task_script_config       = "${root}/script_config.json"
    $task_max_timeout         = 1800
    $worker_group             = 'balrogworker-v1'
    $verbose_logging          = true

    $env_config = {
        'dev' => {
            balrog_api_root => 'https://admin-stage.balrog.nonprod.cloudops.mozgcp.net/api',
            dummy => false,
            taskcluster_client_id => 'project/releng/scriptworker/balrogworker-dev',
            taskcluster_access_token => secret('balrogworker_dev_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:releng:balrog:',
            cot_product => 'firefox',
            worker_type => 'balrog-dev',
            sign_chain_of_trust => false,
            verify_chain_of_trust => true,
            verify_cot_signature => false,
            auth0_domain => 'auth.mozilla.auth0.com',
            auth0_client_id => secret('balrog_auth0_client_id_stage'),
            auth0_client_secret => secret('balrog_auth0_client_secret_stage'),
            auth0_audience => 'balrog-cloudops-stage',
        },
        'prod' => {
            balrog_api_root => 'https://aus4-admin.mozilla.org/api',
            dummy => false,
            taskcluster_client_id => 'project/releng/scriptworker/balrogworker',
            taskcluster_access_token => secret('balrogworker_prod_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:releng:balrog:',
            cot_product => 'firefox',
            worker_type => 'balrogworker-v1',
            sign_chain_of_trust => true,
            verify_chain_of_trust => true,
            verify_cot_signature => true,
            auth0_domain => 'auth.mozilla.auth0.com',
            auth0_client_id => secret('balrog_auth0_client_id_prod'),
            auth0_client_secret => secret('balrog_auth0_client_secret_prod'),
            auth0_audience => 'balrog-production',
        },
        'comm-thunderbird-dev' => {
            balrog_api_root => 'https://admin-stage.balrog.nonprod.cloudops.mozgcp.net/api',
            dummy => false,
            taskcluster_client_id => 'project/comm/thunderbird/releng/scriptworker/balrogworker/dev',
            taskcluster_access_token => secret('comm_thunderbird_balrogworker_dev_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:comm:thunderbird:releng:balrog:',
            cot_product => 'thunderbird',
            worker_type => 'tb-balrog-dev',
            sign_chain_of_trust => false,
            verify_chain_of_trust => true,
            verify_cot_signature => false,
            auth0_domain => 'auth.mozilla.auth0.com',
            auth0_client_id => secret('balrog_auth0_tb_client_id_stage'),
            auth0_client_secret => secret('balrog_auth0_tb_client_secret_stage'),
            auth0_audience => 'balrog-stage',
        },
        'comm-thunderbird-prod' => {
            balrog_api_root => 'https://aus4-admin.mozilla.org/api',
            dummy => false,
            taskcluster_client_id => 'project/comm/thunderbird/releng/scriptworker/balrogworker/prod',
            taskcluster_access_token => secret('comm_thunderbird_balrogworker_prod_taskcluster_access_token'),
            taskcluster_scope_prefix => 'project:comm:thunderbird:releng:balrog:',
            cot_product => 'thunderbird',
            worker_type => 'tb-balrog-v1',
            worker_group => 'balrogworker-v1',
            sign_chain_of_trust => true,
            verify_chain_of_trust => true,
            verify_cot_signature => true,
            auth0_domain => 'auth.mozilla.auth0.com',
            auth0_client_id => secret('balrog_auth0_tb_client_id_prod'),
            auth0_client_secret => secret('balrog_auth0_tb_client_secret_prod'),
            auth0_audience => 'balrog-production',
        },
    }
}
