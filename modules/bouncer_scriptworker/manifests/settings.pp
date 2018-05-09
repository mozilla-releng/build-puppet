# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class bouncer_scriptworker::settings {
    include ::config
    include users::builder
    include python3::settings

    $root                       = $config::scriptworker_root
    $python3_virtualenv_version = $python3::settings::python3_virtualenv_version

    $bouncer_stage_instance_scope = 'project:releng:bouncer:server:staging'
    $bouncer_stage_instance_config = {
        api_root                  => 'https://admin-bouncer-releng.stage.mozaws.net/api',
        timeout_in_seconds        => 60,
        username                  => 'ffxbld',
        # TODO Split credentials
        password                  => secret('tuxedo_password'),
    }

    $_env_configs             = {
      'dev'  => {
        worker_group             => 'bouncer-dev',
        worker_type              => 'bouncer-dev',
        verbose_logging          => true,
        taskcluster_client_id    => 'project/releng/scriptworker/bouncer/dev',
        taskcluster_access_token => secret('bouncer_scriptworker_taskcluster_access_token_dev'),

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,

        bouncer_instances        => {
            "${bouncer_stage_instance_scope}" => $bouncer_stage_instance_config,
        },
      },
      'prod' => {
        worker_group             => 'bouncer-v1',
        worker_type              => 'bouncer-v1',
        verbose_logging          => true,
        taskcluster_client_id    => 'project/releng/scriptworker/bouncer/production',
        taskcluster_access_token => secret('bouncer_scriptworker_taskcluster_access_token_prod'),

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,

        bouncer_instances        => {
            "${bouncer_stage_instance_scope}"   => $bouncer_stage_instance_config,
            'project:releng:bouncer:server:production' => {
                api_root                  => 'https://bounceradmin.mozilla.com/api',
                timeout_in_seconds        => 60,
                username                  => 'ffxbld',
                # TODO Split credentials
                password                  => secret('tuxedo_password'),
            },
        },
      },
    }

    $_env_config                = $_env_configs[$bouncer_scriptworker_env]
    $work_dir                   = "${root}/work"
    $task_script                = "${root}/bin/bouncerscript"

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
        schema_files       => {
            submission => "${root}/lib/python${python3_virtualenv_version}/site-packages/bouncerscript/data/bouncer_submission_task_schema.json",
            aliases    => "${root}/lib/python${python3_virtualenv_version}/site-packages/bouncerscript/data/bouncer_aliases_task_schema.json",
        },
        verbose            => $verbose_logging,
        bouncer_config     => $_env_config['bouncer_instances'],
    }
}
