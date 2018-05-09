# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class shipit_scriptworker::settings {
    include ::config
    include users::builder
    include python3::settings

    $root                       = $config::scriptworker_root
    $python3_virtualenv_version = $python3::settings::python3_virtualenv_version

    $ship_it_stage_instance_scope = 'project:releng:ship-it:staging'
    $ship_it_stage_instance_config = {
        api_root                  => 'https://ship-it-dev.allizom.org',
        timeout_in_seconds        => 60,
        username                  => 'shipit-scriptworker-stage',
        password                  => secret('shipit_scriptworker_ship_it_password_dev'),
    }

    $_env_configs             = {
      'dev'  => {
        worker_group             => 'shipit-dev',
        worker_type              => 'shipit-dev',
        verbose_logging          => true,
        taskcluster_client_id    => 'project/releng/scriptworker/shipit/dev',
        taskcluster_access_token => secret('shipit_scriptworker_taskcluster_access_token_dev'),

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,

        ship_it_instances        => {
            "${ship_it_stage_instance_scope}" => $ship_it_stage_instance_config,
        },
      },
      'prod' => {
        worker_group             => 'shipit-v1',
        worker_type              => 'shipit-v1',
        verbose_logging          => true,
        taskcluster_client_id    => 'project/releng/scriptworker/shipit/production',
        taskcluster_access_token => secret('shipit_scriptworker_taskcluster_access_token_prod'),

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,

        ship_it_instances        => {
            "${ship_it_stage_instance_scope}"   => $ship_it_stage_instance_config,
            'project:releng:ship-it:production' => {
                api_root                  => 'https://ship-it.mozilla.org',
                timeout_in_seconds        => 60,
                username                  => 'shipit-scriptworker',
                password                  => secret('shipit_scriptworker_ship_it_password_prod'),
            },
        },
      },
    }

    $_env_config                = $_env_configs[$shipit_scriptworker_env]
    $schema_file                = "${root}/lib/python${python3_virtualenv_version}/site-packages/shipitscript/data/shipit_task_schema.json"
    $work_dir                   = "${root}/work"
    $task_script                = "${root}/bin/shipitscript"

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
        schema_file        => $schema_file,
        verbose            => $verbose_logging,
        ship_it_instances  => $_env_config['ship_it_instances'],
    }
}
