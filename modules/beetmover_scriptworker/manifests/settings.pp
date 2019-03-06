# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class beetmover_scriptworker::settings {
    include python3::settings

    $root                     = '/builds/scriptworker'
    $task_script              = "${root}/bin/beetmoverscript"
    $task_script_config       = "${root}/script_config.json"
    $task_max_timeout         = 1800

    $verbose_logging          = true

    $env_config = {
        'dev' => {
            dep_beetmover_aws_access_key_id         => secret('stage-beetmover-aws_access_key_id'),
            dep_beetmover_aws_secret_access_key     => secret('stage-beetmover-aws_secret_access_key'),
            dep_buckets => {
                devedition  => 'net-mozaws-stage-delivery-archive',
                firefox     => 'net-mozaws-stage-delivery-firefox',
                fennec      => 'net-mozaws-stage-delivery-archive',
                mobile      => 'net-mozaws-stage-delivery-archive',
            },

            dep_partner_beetmover_aws_access_key_id => secret('dep_partner_beetmover_aws_access_key_id'),
            dep_partner_beetmover_aws_secret_access_key => secret('dep_partner_beetmover_aws_secret_access_key'),
            dep_partner_buckets => {
                firefox     => 'mozilla-releng-dep-partner',
            },

            dep_maven_beetmover_aws_access_key_id => secret('dep_maven_geckoview_beetmover_aws_access_key_id'),
            dep_maven_beetmover_aws_secret_access_key => secret('dep_maven_geckoview_beetmover_aws_secret_access_key'),
            dep_maven_buckets => {
                geckoview   => 'maven-default-s3-upload-bucket-13gy5ufwa3qv',
            },

            worker_type                             => 'beetmoverworker-dev',
            worker_group                            => 'beetmoverworker-v1',
            taskcluster_client_id                   => 'project/releng/scriptworker/beetmover-dev',
            taskcluster_access_token                => secret('beetmoverworker_dev_taskcluster_access_token'),
            taskcluster_scope_prefix                => 'project:releng:beetmover:',
            sign_chain_of_trust                     => false,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => false,
            cot_product                             => 'firefox',
            github_oauth_token                      => '',
        },
        'prod' => {
            nightly_beetmover_aws_access_key_id     => secret('nightly-beetmover-aws_access_key_id'),
            nightly_beetmover_aws_secret_access_key => secret('nightly-beetmover-aws_secret_access_key'),
            nightly_buckets => {
                devedition => 'net-mozaws-prod-delivery-archive',
                firefox    => 'net-mozaws-prod-delivery-firefox',
                fennec     => 'net-mozaws-prod-delivery-archive',
                mobile     => 'net-mozaws-prod-delivery-archive',
            },

            release_beetmover_aws_access_key_id     => secret('beetmover-aws_access_key_id'),
            release_beetmover_aws_secret_access_key => secret('beetmover-aws_secret_access_key'),
            release_buckets => {
                devedition  => 'net-mozaws-prod-delivery-archive',
                firefox     => 'net-mozaws-prod-delivery-firefox',
                fennec      => 'net-mozaws-prod-delivery-archive',
                mobile      => 'net-mozaws-prod-delivery-archive',
            },

            partner_beetmover_aws_access_key_id => secret('partner_beetmover_aws_access_key_id'),
            partner_beetmover_aws_secret_access_key => secret('partner_beetmover_aws_secret_access_key'),
            partner_buckets => {
                firefox     => 'fxpartners-distros',
            },

            dep_beetmover_aws_access_key_id         => secret('stage-beetmover-aws_access_key_id'),
            dep_beetmover_aws_secret_access_key     => secret('stage-beetmover-aws_secret_access_key'),
            dep_buckets => {
                devedition  => 'net-mozaws-stage-delivery-archive',
                firefox     => 'net-mozaws-stage-delivery-firefox',
                fennec      => 'net-mozaws-stage-delivery-archive',
                mobile      => 'net-mozaws-stage-delivery-archive',
            },

            dep_partner_beetmover_aws_access_key_id => secret('dep_partner_beetmover_aws_access_key_id'),
            dep_partner_beetmover_aws_secret_access_key => secret('dep_partner_beetmover_aws_secret_access_key'),
            dep_partner_buckets => {
                firefox     => 'mozilla-releng-dep-partner',
            },

            prod_maven_beetmover_aws_access_key_id => secret('prod_maven_geckoview_beetmover_aws_access_key_id'),
            prod_maven_beetmover_aws_secret_access_key => secret('prod_maven_geckoview_beetmover_aws_secret_access_key'),
            prod_maven_buckets => {
                geckoview   => 'maven-default-s3-upload-bucket-1705kkmo2aj3c',
            },

            worker_type                             => 'beetmoverworker-v1',
            worker_group                            => 'beetmoverworker-v1',
            taskcluster_client_id                   => 'project/releng/scriptworker/beetmoverworker',
            taskcluster_access_token                => secret('beetmoverworker_prod_taskcluster_access_token'),
            taskcluster_scope_prefix                => 'project:releng:beetmover:',
            sign_chain_of_trust                     => true,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => true,
            cot_product                             => 'firefox',
            github_oauth_token                      => '',
        },
        'comm-thunderbird-dev' => {
            dep_beetmover_aws_access_key_id         => secret('comm_thunderbird_dev-beetmover-aws_access_key_id'),
            dep_beetmover_aws_secret_access_key     => secret('comm_thunderbird_dev-beetmover-aws_secret_access_key'),
            dep_buckets                             => {
                'thunderbird' => 'net-mozaws-stage-delivery-archive',
            },

            worker_type                             => 'tb-beetmover-dev',
            worker_group                            => 'beetmoverworker-v1',
            taskcluster_client_id                   => 'project/comm/thunderbird/releng/scriptworker/beetmover/dev',
            taskcluster_access_token                => secret('comm_thunderbird_beetmoverworker_dev_taskcluster_access_token'),
            taskcluster_scope_prefix                => 'project:comm:thunderbird:releng:beetmover:',
            sign_chain_of_trust                     => false,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => false,
            cot_product                             => 'thunderbird',
            github_oauth_token                      => '',
        },
        'comm-thunderbird-prod' => {
            nightly_beetmover_aws_access_key_id     => secret('comm_nightly-beetmover-aws_access_key_id'),
            nightly_beetmover_aws_secret_access_key => secret('comm_nightly-beetmover-aws_secret_access_key'),
            nightly_buckets                             => {
                'thunderbird' => 'net-mozaws-prod-delivery-archive',
            },

            release_beetmover_aws_access_key_id     => secret('comm_beetmover-aws_access_key_id'),
            release_beetmover_aws_secret_access_key => secret('comm_beetmover-aws_secret_access_key'),
            release_buckets => {
                'thunderbird' => 'net-mozaws-prod-delivery-archive',
            },

            dep_beetmover_aws_access_key_id         => secret('comm_thunderbird_dev-beetmover-aws_access_key_id'),
            dep_beetmover_aws_secret_access_key     => secret('comm_thunderbird_dev-beetmover-aws_secret_access_key'),
            dep_buckets                             => {
                'thunderbird' => 'net-mozaws-stage-delivery-archive',
            },

            worker_type                             => 'tb-beetmover-v1',
            worker_group                            => 'beetmoverworker-v1',
            taskcluster_client_id                   => 'project/comm/thunderbird/releng/scriptworker/beetmover/prod',
            taskcluster_access_token                => secret('comm_thunderbird_beetmoverworker_prod_taskcluster_access_token'),
            taskcluster_scope_prefix                => 'project:comm:thunderbird:releng:beetmover:',
            sign_chain_of_trust                     => true,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => true,
            cot_product                             => 'thunderbird',
            github_oauth_token                      => '',
        },
        'mobile-dev' => {
            dep_maven_beetmover_aws_access_key_id => secret('dep_maven_android_components_beetmover_aws_access_key_id'),
            dep_maven_beetmover_aws_secret_access_key => secret('dep_maven_android_components_beetmover_aws_secret_access_key'),
            dep_maven_buckets => {
                components   => 'maven-default-s3-upload-bucket-13gy5ufwa3qv',
            },

            dep_snapshot_maven_beetmover_aws_access_key_id => secret('snapshot_stage_maven_android_components_beetmover_aws_access_key_id'),
            dep_snapshot_maven_beetmover_aws_secret_access_key => secret('snapshot_stage_maven_android_components_beetmover_aws_secret_access_key'),
            dep_snapshot_maven_buckets => {
                snapshot_components   => 'maven-snapshots-s3-upload-bucket-knc0jfluv2kn',
            },

            worker_type                             => 'mobile-beetmover-dev',
            worker_group                            => 'mobile-beetmover-v1',
            taskcluster_client_id                   => 'project/mobile/android-components/releng/scriptworker/beetmover/dev',
            taskcluster_access_token                => secret('beetmoverworker_dev_taskcluster_access_token_mobile'),
            taskcluster_scope_prefix                => 'project:mobile:android-components:releng:beetmover:',
            sign_chain_of_trust                     => false,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => false,
            cot_product                             => 'mobile',
            github_oauth_token                      => secret('scriptworker_github_oauth_token_staging'),
        },
        'mobile-prod' => {
            prod_maven_beetmover_aws_access_key_id => secret('prod_maven_android_components_beetmover_aws_access_key_id'),
            prod_maven_beetmover_aws_secret_access_key => secret('prod_maven_android_components_beetmover_aws_secret_access_key'),
            prod_maven_buckets => {
                components   => 'maven-default-s3-upload-bucket-1705kkmo2aj3c',
            },

            prod_snapshot_maven_beetmover_aws_access_key_id => secret('snapshot_prod_maven_android_components_beetmover_aws_access_key_id'),
            prod_snapshot_maven_beetmover_aws_secret_access_key => secret('snapshot_prod_maven_android_components_beetmover_aws_secret_access_key'),
            prod_snapshot_maven_buckets => {
                snapshot_components   => 'maven-snapshots-s3-upload-bucket-d4zm9oo354qe',
            },

            worker_type                             => 'mobile-beetmover-v1',
            worker_group                            => 'mobile-beetmover-v1',
            taskcluster_client_id                   => 'project/mobile/android-components/releng/scriptworker/beetmover/production',
            taskcluster_access_token                => secret('beetmoverworker_prod_taskcluster_access_token_mobile'),
            taskcluster_scope_prefix                => 'project:mobile:android-components:releng:beetmover:',
            sign_chain_of_trust                     => true,
            verify_chain_of_trust                   => true,
            verify_cot_signature                    => true,
            cot_product                             => 'mobile',
            github_oauth_token                      => secret('scriptworker_github_oauth_token_production'),
        }
    }
}
