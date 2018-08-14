# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class bouncer_scriptworker::settings {
    include ::config
    include users::builder
    include python3::settings

    $root                       = $config::scriptworker_root
    $script_config              = "${root}/script_config.json"
    $task_script                = "${root}/bin/bouncerscript"
    $verbose_logging            = true

    $bouncer_stage_instance_scope = 'project:releng:bouncer:server:staging'
    $bouncer_stage_instance_config = {
        api_root                  => 'https://admin-bouncer-releng.stage.mozaws.net/api',
        timeout_in_seconds        => 60,
        username                  => 'releng-ffx-staging',
        # TODO Split credentials
        password                  => secret('ffx-bouncer-staging_password'),
    }

    $env_config = {
      'dev'  => {
        worker_group             => 'bouncer-dev',
        worker_type              => 'bouncer-dev',
        taskcluster_client_id    => 'project/releng/scriptworker/bouncer/dev',
        taskcluster_access_token => secret('bouncer_scriptworker_taskcluster_access_token_dev'),
        taskcluster_scope_prefix => 'project:releng:bouncer:',

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,
        cot_product              => 'firefox',

        bouncer_instances        => {
            "${bouncer_stage_instance_scope}" => $bouncer_stage_instance_config,
        },
      },
      'prod' => {
        worker_group             => 'bouncer-v1',
        worker_type              => 'bouncer-v1',
        taskcluster_client_id    => 'project/releng/scriptworker/bouncer/production',
        taskcluster_access_token => secret('bouncer_scriptworker_taskcluster_access_token_prod'),
        taskcluster_scope_prefix => 'project:releng:bouncer:',

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,
        cot_product              => 'firefox',

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
      'comm-thunderbird-dev' => {
        worker_group             => 'bouncer-v1',
        worker_type              => 'tb-bouncer-dev',
        taskcluster_client_id    => 'project/comm/thunderbird/releng/scriptworker/bouncer/dev',
        taskcluster_access_token => secret('comm_thunderbird_bouncer_scriptworker_taskcluster_access_token_dev'),
        taskcluster_scope_prefix => 'project:comm:thunderbird:releng:bouncer:',

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,
        cot_product              => 'thunderbird',
        bouncer_instances        => {
          "project:comm:thunderbird:releng:bouncer:server:staging" => {
            api_root                  => 'https://admin-bouncer-releng.stage.mozaws.net/api',
            timeout_in_seconds        => 60,
            username                  => 'releng-tbird-staging',
            password                  => secret('tbird-bouncer-staging_password'),
          },
        },
      },
      'comm-thunderbird-prod' => {
        worker_group             => 'bouncer-v1',
        worker_type              => 'tb-bouncer-v1',
        taskcluster_client_id    => 'project/comm/thunderbird/releng/scriptworker/bouncer/prod',
        taskcluster_access_token => secret('comm_thunderbird_bouncer_scriptworker_taskcluster_access_token_prod'),
        taskcluster_scope_prefix => 'project:comm:thunderbird:releng:bouncer:',
        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,
        cot_product              => 'thunderbird',
        bouncer_instances        => {
          "project:comm:thunderbird:releng:bouncer:server:staging" => {
            api_root                  => 'https://admin-bouncer-releng.stage.mozaws.net/api',
            timeout_in_seconds        => 60,
            username                  => 'releng-tbird-staging',
            password                  => secret('tbird-bouncer-staging_password'),
          },
          'project:comm:thunderbird:releng:bouncer:server:production' => {
            api_root                  => 'https://bounceradmin.mozilla.com/api',
            timeout_in_seconds        => 60,
            username                  => 'ffxbld',
            # TODO Split credentials
            password                  => secret('tuxedo_password'),
          },
        },
      },
    }
}
