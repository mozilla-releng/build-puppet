class signing_scriptworker::settings {
    $root = "/builds/scriptworker"
    $worker_group = "signing-linux-v1"
    $worker_type = "signing-linux-v1"
    $taskcluster_client_id = secret("signing_scriptworker_taskcluster_client_id")
    $taskcluster_access_token = secret("signing_scriptworker_taskcluster_access_token")
    $task_script_executable = "${root}/bin/python"
    $task_script = "${root}/bin/signingscript"
    $task_script_config = "${root}/script_config.json"
    $task_max_timeout = 1800
}
