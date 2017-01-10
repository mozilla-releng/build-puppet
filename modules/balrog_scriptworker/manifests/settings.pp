class balrog_scriptworker::settings {
    $root = "/builds/balrogworker"
    $task_script_executable = "${root}/py27venv/bin/python"
    $task_script = "${root}/py27venv/bin/balrogscript"
    $task_script_config = "${root}/script_config.json"
    $task_max_timeout = 1800
    $tools_repo = 'https://hg.mozilla.org/build/tools'
    $tools_branch = 'default'
    $worker_group = "test-dummy-workers"
    $worker_type = "dummy-worker-mtabara"
    $taskcluster_client_id = secret("balrogworker_dev_taskcluster_client_id")
    $taskcluster_access_token = secret("balrogworker_dev_taskcluster_access_token")
    $verbose_logging = true

    $env_config = {
        "dev" => {
            balrog_username => "stage-ffxbld",
            balrog_password => secret("stage-ffxbld_ldap_password"),
            balrog_api_root => "https://balrog-admin.stage.mozaws.net/api"
        }
    }
}
