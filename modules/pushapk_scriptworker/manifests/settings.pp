# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker::settings {
    include ::config
    include users::builder
    include python3::settings

    $root                                = $config::scriptworker_root
    $python3_virtualenv_version          = $python3::settings::python3_virtualenv_version

    $_env_configs                        = {
      'dep'  => {
        worker_group             => 'dep-pushapk',
        worker_type              => 'dep-pushapk',
        verbose_logging          => true,
        taskcluster_client_id    => secret('pushapk_scriptworker_taskcluster_client_id_dep'),
        taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_dep'),
        scope_prefix             => 'project:releng:googleplay:',
        cot_product              => 'firefox',

        sign_chain_of_trust      => false,
        verify_chain_of_trust    => true,
        verify_cot_signature     => false,
      },
      'prod' => {
        worker_group             => 'pushapk-v1',
        worker_type              => 'pushapk-v1',
        verbose_logging          => true,
        taskcluster_client_id    => secret('pushapk_scriptworker_taskcluster_client_id_prod'),
        taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_prod'),
        scope_prefix             => 'project:releng:googleplay:',
        cot_product              => 'firefox',

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,
      },
      'mobile-prod' => {
        worker_group             => 'mobile-pushapk-v1',
        worker_type              => 'mobile-pushapk-v1',
        verbose_logging          => true,
        taskcluster_client_id    => 'project/mobile/focus/releng/scriptworker/pushapk/production',
        taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_mobile'),
        scope_prefix             => 'project:mobile:focus:releng:googleplay:product:',
        cot_product              => 'mobile',

        sign_chain_of_trust      => true,
        verify_chain_of_trust    => true,
        verify_cot_signature     => true,
      },
    }

    $_env_config                         = $_env_configs[$pushapk_scriptworker_env]
    $schema_file                         = "${root}/lib/python${python3_virtualenv_version}/site-packages/pushapkscript/data/pushapk_task_schema.json"
    $work_dir                            = "${root}/work"
    $task_script                         = "${root}/bin/pushapkscript"

    $user = $users::builder::username
    $group = $users::builder::group

    $taskcluster_client_id               = $_env_config['taskcluster_client_id']
    $taskcluster_access_token            = $_env_config['taskcluster_access_token']
    $worker_group                        = $_env_config['worker_group']
    $worker_type                         = $_env_config['worker_type']

    $sign_chain_of_trust                 = $_env_config['sign_chain_of_trust']
    $verify_chain_of_trust               = $_env_config['verify_chain_of_trust']
    $verify_cot_signature                = $_env_config['verify_cot_signature']
    $cot_product                         = $_env_config['cot_product']

    $_google_play_all_accounts           = hiera_hash('pushapk_scriptworker_google_play_accounts')
    $_google_play_accounts               = $_google_play_all_accounts[$fqdn]

    # TODO: Replace this cumbersome logic by an `each` loop once we switch to Puppet 4
    case $pushapk_scriptworker_env {
        'dep': {
            $google_play_config = {
                'dep'  => {
                    service_account             => $_google_play_accounts['dep']['service_account'],
                    certificate                 => $_google_play_accounts['dep']['certificate'],
                    certificate_target_location => "${root}/dep.p12",
                },
            }
            $google_play_accounts_config_content = {
                'dep' => {
                  'service_account' => $google_play_config['dep']['service_account'],
                  'certificate' => $google_play_config['dep']['certificate_target_location'],
                }
            }
            $jarsigner_certificate_aliases_content = {
                'dep' => 'dep',
            }
        }
        'prod': {
            $google_play_config = {
                'aurora'  => {
                    service_account             => $_google_play_accounts['aurora']['service_account'],
                    certificate                 => $_google_play_accounts['aurora']['certificate'],
                    certificate_target_location => "${root}/aurora.p12",
                },
                'beta'    => {
                    service_account             => $_google_play_accounts['beta']['service_account'],
                    certificate                 => $_google_play_accounts['beta']['certificate'],
                    certificate_target_location => "${root}/beta.p12",
                },
                'release' => {
                    service_account             => $_google_play_accounts['release']['service_account'],
                    certificate                 => $_google_play_accounts['release']['certificate'],
                    certificate_target_location => "${root}/release.p12",
                },
            }
            $google_play_accounts_config_content = {
              'aurora' => {
                'service_account' => $google_play_config['aurora']['service_account'],
                'certificate' => $google_play_config['aurora']['certificate_target_location'],
              },
              'beta' => {
                'service_account' => $google_play_config['beta']['service_account'],
                'certificate' => $google_play_config['beta']['certificate_target_location'],
              },
              'release' => {
                'service_account' => $google_play_config['release']['service_account'],
                'certificate' => $google_play_config['release']['certificate_target_location'],
              },
            }
            $jarsigner_certificate_aliases_content = {
              'aurora'  => 'nightly',
              'beta'    => 'release',
              'release' => 'release',
            }
        }
        'mobile-prod': {
            $google_play_config = {
                'focus'  => {
                    service_account             => $_google_play_accounts['focus']['service_account'],
                    certificate                 => $_google_play_accounts['focus']['certificate'],
                    certificate_target_location => "${root}/focus.p12",
                },
            }
            $google_play_accounts_config_content = {
                'focus' => {
                  'service_account' => $google_play_config['focus']['service_account'],
                  'certificate' => $google_play_config['focus']['certificate_target_location'],
                }
            }
            $jarsigner_certificate_aliases_content = {
                'focus' => 'focus',
            }
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }

    $jarsigner_keystore                  = "${root}/mozilla-android-keystore"
    $jarsigner_keystore_password         = secret('pushapk_scriptworker_jarsigner_keystore_password')

    $jarsigner_all_certificates = {
        'nightly' => "${root}/nightly.cer",
        'release' => "${root}/release.cer",
        'dep'     => "${root}/dep.cer",
        'focus'   => "${root}/focus.cer",
    }

    $verbose_logging                     = $_env_config['verbose_logging']

    $script_config                       = "${root}/script_config.json"
    $script_config_content = {
        'work_dir'   => $work_dir,
        'schema_file'=> $schema_file,
        'verbose'    => $verbose_logging,

        'google_play_accounts' => $google_play_accounts_config_content,
        'jarsigner_key_store' => $jarsigner_keystore,
        'jarsigner_certificate_aliases' => $jarsigner_certificate_aliases_content,

        'taskcluster_scope_prefix' => $_env_config['scope_prefix'],
    }
}
