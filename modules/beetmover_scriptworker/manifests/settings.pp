# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class beetmover_scriptworker::settings {
    $root                     = '/builds/scriptworker'
    $task_script              = "${root}/bin/beetmoverscript"
    $task_script_config       = "${root}/script_config.json"
    $task_max_timeout         = 1800

    $worker_group             = 'beetmoverworker-v1'
    $verbose_logging          = true

    $env_config = {
        'dev' => {
            nightly_beetmover_aws_access_key_id     => secret('stage-beetmover-aws_access_key_id'),
            nightly_beetmover_aws_secret_access_key => secret('stage-beetmover-aws_secret_access_key'),
            nightly_beetmover_aws_s3_firefox_bucket => 'net-mozaws-stage-delivery-firefox',
            nightly_beetmover_aws_s3_fennec_bucket  => 'net-mozaws-stage-delivery-archive',

            release_beetmover_aws_access_key_id     => secret('stage-beetmover-aws_access_key_id'),
            release_beetmover_aws_secret_access_key => secret('stage-beetmover-aws_secret_access_key'),
            release_beetmover_aws_s3_firefox_bucket => 'net-mozaws-stage-delivery-firefox',
            release_beetmover_aws_s3_fennec_bucket  => 'net-mozaws-stage-delivery-archive',

            dep_beetmover_aws_access_key_id         => secret('stage-beetmover-aws_access_key_id'),
            dep_beetmover_aws_secret_access_key     => secret('stage-beetmover-aws_secret_access_key'),
            dep_beetmover_aws_s3_firefox_bucket     => 'net-mozaws-stage-delivery-firefox',
            dep_beetmover_aws_s3_fennec_bucket      => 'net-mozaws-stage-delivery-archive',

            config_template                         => 'beetmover_scriptworker/dev_script_config.json.erb',
            worker_type                             => 'beetmoverworker-dev',
            taskcluster_client_id                   => 'project/releng/scriptworker/beetmover-dev',
            taskcluster_access_token                => secret('beetmoverworker_dev_taskcluster_access_token'),
            sign_chain_of_trust                     => false,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => false,
        },
        'prod' => {
            nightly_beetmover_aws_access_key_id     => secret('nightly-beetmover-aws_access_key_id'),
            nightly_beetmover_aws_secret_access_key => secret('nightly-beetmover-aws_secret_access_key'),
            nightly_beetmover_aws_s3_firefox_bucket => 'net-mozaws-prod-delivery-firefox',
            nightly_beetmover_aws_s3_fennec_bucket  => 'net-mozaws-prod-delivery-archive',

            release_beetmover_aws_access_key_id     => secret('beetmover-aws_access_key_id'),
            release_beetmover_aws_secret_access_key => secret('beetmover-aws_secret_access_key'),
            release_beetmover_aws_s3_firefox_bucket => 'net-mozaws-prod-delivery-firefox',
            release_beetmover_aws_s3_fennec_bucket  => 'net-mozaws-prod-delivery-archive',

            dep_beetmover_aws_access_key_id         => secret('stage-beetmover-aws_access_key_id'),
            dep_beetmover_aws_secret_access_key     => secret('stage-beetmover-aws_secret_access_key'),
            dep_beetmover_aws_s3_firefox_bucket     => 'net-mozaws-stage-delivery-firefox',
            dep_beetmover_aws_s3_fennec_bucket      => 'net-mozaws-stage-delivery-archive',

            config_template                         => 'beetmover_scriptworker/prod_script_config.json.erb',
            worker_type                             => 'beetmoverworker-v1',
            taskcluster_client_id                   => 'project/releng/scriptworker/beetmoverworker',
            taskcluster_access_token                => secret('beetmoverworker_prod_taskcluster_access_token'),
            sign_chain_of_trust                     => true,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => true,
        }
    }
}
