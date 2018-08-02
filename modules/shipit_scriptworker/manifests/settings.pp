# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class shipit_scriptworker::settings {
    include ::config
    include users::builder
    include python3::settings

    $root                       = $config::scriptworker_root
    $python3_virtualenv_version = $python3::settings::python3_virtualenv_version

    $ship_it_stage_instance_scope = 'project:releng:ship-it:server:staging'
    $ship_it_stage_instance_config = {
        api_root                  => 'https://ship-it-dev.allizom.org',
        timeout_in_seconds        => 60,
        username                  => 'shipit-scriptworker-stage',
        password                  => secret('shipit_scriptworker_ship_it_password_dev'),
    }

    $env_config = {
      'dev'  => {
        worker_group             => 'shipit-dev',
        worker_type              => 'shipit-dev',
        taskcluster_client_id    => 'project/releng/scriptworker/shipit/dev',
        taskcluster_access_token => secret('shipit_scriptworker_taskcluster_access_token_dev'),
        taskcluster_scope_prefix => 'project:releng:ship-it:',

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,
        cot_product              => 'firefox',

        ship_it_instances        => {
            "${ship_it_stage_instance_scope}" => $ship_it_stage_instance_config,
        },
      },
      'prod' => {
        worker_group             => 'shipit-v1',
        worker_type              => 'shipit-v1',
        taskcluster_client_id    => 'project/releng/scriptworker/shipit/production',
        taskcluster_access_token => secret('shipit_scriptworker_taskcluster_access_token_prod'),
        taskcluster_scope_prefix => 'project:releng:ship-it:',

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,
        cot_product              => 'firefox',

        ship_it_instances        => {
            "${ship_it_stage_instance_scope}"   => $ship_it_stage_instance_config,
            'project:releng:ship-it:server:production' => {
                api_root                  => 'https://ship-it.mozilla.org',
                timeout_in_seconds        => 60,
                username                  => 'shipit-scriptworker',
                password                  => secret('shipit_scriptworker_ship_it_password_prod'),
            },
        },
      },
      'tb-dev'  => {
        worker_group             => 'shipit-v1',
        worker_type              => 'tb-shipit-dev',
        taskcluster_client_id    => 'project/comm/thunderbird/releng/scriptworker/shipit/dev',
        taskcluster_access_token => secret('comm_thunderbird_shipit_scriptworker_taskcluster_access_token_dev'),
        taskcluster_scope_prefix => 'project:comm:thunderbird:releng:ship-it:',

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,
        cot_product              => 'thunderbird',

        ship_it_instances        => {
            "project:comm:thunderbird:releng:ship-it:staging" => $ship_it_stage_instance_config,
        },
      },
      'tb-prod'  => {
        worker_group             => 'shipit-v1',
        worker_type              => 'tb-shipit-v1',
        taskcluster_client_id    => 'project/comm/thunderbird/releng/scriptworker/shipit/prod',
        taskcluster_access_token => secret('comm_thunderbird_shipit_scriptworker_taskcluster_access_token_prod'),
        taskcluster_scope_prefix => 'project:comm:thunderbird:releng:ship-it:',

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,
        cot_product              => 'thunderbird',

        ship_it_instances        => {
            "project:comm:thunderbird:releng:ship-it:staging" => $ship_it_stage_instance_config,
            'project:comm:thunderbird:releng:ship-it:production' => {
                api_root                  => 'https://ship-it.mozilla.org',
                timeout_in_seconds        => 60,
                username                  => 'shipit-scriptworker',
                password                  => secret('shipit_scriptworker_ship_it_password_prod'),
            },
        },
      },
    }

    $mark_as_shipped_schema_file = "${root}/lib/python${python3_virtualenv_version}/site-packages/shipitscript/data/mark_as_shipped_task_schema.json"
    $mark_as_started_schema_file = "${root}/lib/python${python3_virtualenv_version}/site-packages/shipitscript/data/mark_as_started_task_schema.json"
    $work_dir                   = "${root}/work"
    $task_script                = "${root}/bin/shipitscript"

    $user                       = $users::builder::username
    $group                      = $users::builder::group

    $verbose_logging            = true

    $script_config              = "${root}/script_config.json"
}
