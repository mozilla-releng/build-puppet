class beetmover_scriptworker::settings {
    $root = "/builds/scriptworker"
    $task_script = "${root}/bin/beetmoverscript"
    $task_script_config = "${root}/script_config.json"
    $task_max_timeout = 1800

    $worker_group = "beetmoverworker-v1"
    $worker_type = "beetmoverworker-v1"
    $taskcluster_client_id = secret("beetmoverworker_dev_taskcluster_client_id")
    $taskcluster_access_token = secret("beetmoverworker_dev_taskcluster_access_token")
    $verbose_logging = true

    $env_config = {
        "dev" => {
            beetmover_aws_access_key_id => secret("stage-beetmover-aws_access_key_id"),
            beetmover_aws_secret_access_key => secret("stage-beetmover-aws_secret_access_key"),
            beetmover_aws_s3_firefox_bucket => "net-mozaws-stage-delivery-firefox",
            beetmover_aws_s3_fennec_bucket => "net-mozaws-stage-delivery-archive",
        },
        "prod" => {
            beetmover_aws_access_key_id => secret("nightly-beetmover-aws_access_key_id"),
            beetmover_aws_secret_access_key => secret("nightly-beetmover-aws_secret_access_key"),
            beetmover_aws_s3_firefox_bucket => "net-mozaws-prod-delivery-firefox",
            beetmover_aws_s3_fennec_bucket => "net-mozaws-prod-delivery-archive",
        }
    }
}
