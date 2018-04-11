# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class addon_scriptworker::settings {
    include ::config
    include users::builder

    $root                     = $config::scriptworker_root

    $amo_stage_instance_scope = 'project:releng:addons.mozilla.org:server:staging'
    $amo_stage_instance_config = {
        amo_server                => 'https://addons.allizom.org',
        jwt_user                  => 'user:11686445:783',
        jwt_secret                => secret('addon_scriptworker_amo_password_staging'),
    }

    $_env_configs             = {
      'dev'  => {
        worker_group             => 'addon-dev',
        worker_type              => 'addon-dev',
        verbose_logging          => true,
        taskcluster_client_id    => 'project/releng/scriptworker/addon/dev',
        taskcluster_access_token => secret('addon_scriptworker_taskcluster_access_token_dev'),

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,


        amo_instances        => {
            "${amo_stage_instance_scope}" => $amo_stage_instance_config,
        },
      },
      'prod' => {
        worker_group             => 'addon-v1',
        worker_type              => 'addon-v1',
        verbose_logging          => true,
        taskcluster_client_id    => 'project/releng/scriptworker/addon/production',
        taskcluster_access_token => secret('addon_scriptworker_taskcluster_access_token_prod'),

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,

        amo_instances        => {
            "${amo_stage_instance_scope}"   => $amo_stage_instance_config,
            'project:releng:addons.mozilla.org:server:production' => {
                amo_server     => 'https://addons.mozilla.org',
                jwt_user       => 'user:13856839:824',
                jwt_secret     => secret('addon_scriptworker_amo_password_prod'),
            },
        },
      },
    }

    $_env_config                = $_env_configs[$addon_scriptworker_env]
    $work_dir                   = "${root}/work"
    $artifact_dir               = "${root}/artifacts"
    $task_script                = "${root}/bin/addonscript"

    $user                       = $users::builder::username
    $group                      = $users::builder::group

    $taskcluster_client_id      = $_env_config['taskcluster_client_id']
    $taskcluster_access_token   = $_env_config['taskcluster_access_token']
    $worker_group               = $_env_config['worker_group']
    $worker_type                = $_env_config['worker_type']

    $sign_chain_of_trust        = $_env_config['sign_chain_of_trust']
    $verify_chain_of_trust      = $_env_config['verify_chain_of_trust']
    $verify_cot_signature       = $_env_config['verify_cot_signature']

    $verbose_logging            = $_env_config['verbose_logging']

    $script_config              = "${root}/script_config.json"
    $script_config_content      = {
        work_dir           => $work_dir,
        artifact_dir       => $artifact_dir,
        verbose            => $verbose_logging,
        amo_instances      => $_env_config['amo_instances'],
    }
}
