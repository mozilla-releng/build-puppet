# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class signing_scriptworker::settings {
    include ::config
    include python3::settings

    $root               = $config::scriptworker_root
    $task_max_timeout   = 7200
    $task_script        = "${root}/bin/signingscript"
    $task_script_config = "${root}/script_config.json"
    $verbose            = true
    $virtualenv_version = $python3::settings::python3_virtualenv_version

    $env_config = {
        'dev' => {
            worker_type              => 'signing-linux-dev',
            worker_group             => 'signing-linux-v1',
            taskcluster_client_id    => secret('dev_signing_scriptworker_taskcluster_client_id'),
            taskcluster_access_token => secret('dev_signing_scriptworker_taskcluster_access_token'),
            passwords_template       => 'dep-passwords.json.erb',
            scope_prefix             => 'project:releng:signing:',
            sign_chain_of_trust      => false,
            verify_chain_of_trust    => true,
            verify_cot_signature     => false,
            cot_product              => 'firefox',
            datadog_api_key          => secret('scriptworker_datadog_api_key'),
            gpg_keyfile              => 'KEY_dep',
        },
        'dep' => {
            worker_type              => 'depsigning',
            worker_group             => 'signing-linux-v1',
            taskcluster_client_id    => secret('dep_signing_scriptworker_taskcluster_client_id'),
            taskcluster_access_token => secret('dep_signing_scriptworker_taskcluster_access_token'),
            passwords_template       => 'dep-passwords.json.erb',
            scope_prefix             => 'project:releng:signing:',
            sign_chain_of_trust      => false,
            verify_chain_of_trust    => true,
            verify_cot_signature     => false,
            cot_product              => 'firefox',
            datadog_api_key          => secret('scriptworker_datadog_api_key'),
            gpg_keyfile              => 'KEY_dep',
        },
        'prod' => {
            worker_type              => 'signing-linux-v1',
            worker_group             => 'signing-linux-v1',
            taskcluster_client_id    => secret('signing_scriptworker_taskcluster_client_id'),
            taskcluster_access_token => secret('signing_scriptworker_taskcluster_access_token'),
            passwords_template       => 'passwords.json.erb',
            scope_prefix             => 'project:releng:signing:',
            sign_chain_of_trust      => true,
            verify_chain_of_trust    => true,
            verify_cot_signature     => true,
            cot_product              => 'firefox',
            datadog_api_key          => secret('scriptworker_datadog_api_key'),
            gpg_keyfile              => 'KEY_prod',
        },
        'comm-thunderbird-dep' => {
            worker_type              => 'tb-depsigning',
            worker_group             => 'tb-depsigning',
            taskcluster_client_id    => secret('comm_thunderbird_dep_signing_scriptworker_taskcluster_client_id'),
            taskcluster_access_token => secret('comm_thunderbird_dep_signing_scriptworker_taskcluster_access_token'),
            passwords_template       => 'dep-passwords.json.erb',
            scope_prefix             => 'project:comm:thunderbird:releng:signing:',
            sign_chain_of_trust      => false,
            verify_chain_of_trust    => true,
            verify_cot_signature     => false,
            cot_product              => 'thunderbird',
            datadog_api_key          => secret('scriptworker_datadog_api_key'),
            gpg_keyfile              => 'KEY_dep',
        },
        'comm-thunderbird-prod' => {
            worker_type              => 'tb-signing-v1',
            worker_group             => 'signing-linux-v1',
            taskcluster_client_id    => 'project/comm/thunderbird/releng/scriptworker/signingworker',
            taskcluster_access_token => secret('comm_thunderbird_signing_scriptworker_taskcluster_access_token'),
            passwords_template       => 'passwords.json.erb',
            scope_prefix             => 'project:comm:thunderbird:releng:signing:',
            sign_chain_of_trust      => true,
            verify_chain_of_trust    => true,
            verify_cot_signature     => true,
            cot_product              => 'thunderbird',
            datadog_api_key          => secret('scriptworker_datadog_api_key'),
            gpg_keyfile              => 'KEY_prod',
        },
        'mobile-prod' => {
            worker_type              => 'mobile-signing-v1',
            worker_group             => 'mobile-signing-v1',
            taskcluster_client_id    => 'project/mobile/focus/releng/scriptworker/signing/production',
            taskcluster_access_token => secret('mobile_focus_signing_scriptworker_taskcluster_access_token'),
            passwords_template       => 'passwords-mobile.json.erb',
            scope_prefix             => 'project:mobile:focus:releng:signing:',
            sign_chain_of_trust      => true,
            verify_chain_of_trust    => true,
            verify_cot_signature     => true,
            cot_product              => 'mobile',
            datadog_api_key          => secret('scriptworker_datadog_api_key'),
            gpg_keyfile              => 'KEY_dep',
        },
    }
}
