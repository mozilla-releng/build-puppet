class beetmover_scriptworker::settings {
    $root = "/builds/beetmoverworker"
    $task_script_executable = "${root}/bin/python"
    $task_script = "${root}/bin/beetmoverscript"
    $task_script_config = "${root}/script_config.json"
    $task_max_timeout = 1800

    $worker_group = "test-dummy-workers"
    $worker_type = "dummy-worker-mtabara"
    $taskcluster_client_id = secret("beetmoverworker_dev_taskcluster_client_id")
    $taskcluster_access_token = secret("beetmoverworker_dev_taskcluster_access_token")
    $verbose_logging = true

    $env_config = {
        "dev" => {
            beetmover_aws_access_key_id => secret("nightly-beetmover-aws_access_key_id"),
            beetmover_aws_secret_access_key => secret("nightly-beetmover-aws_secret_access_key"),
            beetmover_aws_s3_firefox_bucket => "net-mozaws-prod-delivery-firefox",
            beetmover_aws_s3_fennec_bucket => "net-mozaws-prod-delivery-archive",
        }
    }
}
