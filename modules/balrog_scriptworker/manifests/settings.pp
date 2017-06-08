# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class balrog_scriptworker::settings {
    $root                     = '/builds/scriptworker'
    $task_script_executable   = "${root}/py27venv/bin/python"
    $task_script              = "${root}/py27venv/bin/balrogscript"
    $task_script_config       = "${root}/script_config.json"
    $task_max_timeout         = 1800
    $tools_repo               = 'https://hg.mozilla.org/build/tools'
    $tools_branch             = 'default'
    $worker_group             = 'balrogworker-v1'
    $worker_type              = 'balrogworker-v1'
    $taskcluster_client_id    = secret('balrogworker_dev_taskcluster_client_id')
    $taskcluster_access_token = secret('balrogworker_dev_taskcluster_access_token')
    $verbose_logging          = true

    $env_config = {
        'dev' => {
            balrog_username => 'balrog-stage-ffxbld',
            balrog_password => secret('balrog-stage-ffxbld_ldap_password'),
            balrog_api_root => 'https://balrog-admin.stage.mozaws.net/api',
        },
        'prod' => {
            balrog_username => 'balrog-ffxbld',
            balrog_password => secret('balrog-ffxbld_ldap_password'),
            balrog_api_root => 'https://aus4-admin.mozilla.org/api',
        }
    }
}
