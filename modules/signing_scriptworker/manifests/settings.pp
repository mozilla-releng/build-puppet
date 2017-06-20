class signing_scriptworker::settings {
    include ::config

    $root = $config::scriptworker_root
    $task_max_timeout = 1800
    $task_script = "${root}/bin/signingscript"
    $task_script_config = "${root}/script_config.json"
    $verbose = true
    $worker_group = "signing-linux-v1"

    $env_config = {
        "dev" => {
            worker_type => "signing-linux-dev",
            taskcluster_client_id => secret("dev_signing_scriptworker_taskcluster_client_id"),
            taskcluster_access_token => secret("dev_signing_scriptworker_taskcluster_access_token"),
            passwords_template => "dep-passwords.json.erb",
            sign_chain_of_trust => false,
            verify_chain_of_trust => false,
            verify_cot_signature => false
        },
        "dep" => {
            worker_type => "depsigning",
            taskcluster_client_id => secret("dep_signing_scriptworker_taskcluster_client_id"),
            taskcluster_access_token => secret("dep_signing_scriptworker_taskcluster_access_token"),
            passwords_template => "dep-passwords.json.erb",
            sign_chain_of_trust => false,
            verify_chain_of_trust => true,
            verify_cot_signature => false
        },
        "prod" => {
            worker_type => "signing-linux-v1",
            taskcluster_client_id => secret("signing_scriptworker_taskcluster_client_id"),
            taskcluster_access_token => secret("signing_scriptworker_taskcluster_access_token"),
            passwords_template => "passwords.json.erb",
            sign_chain_of_trust => true,
            verify_chain_of_trust => true,
            verify_cot_signature => true
        }
    }
}
