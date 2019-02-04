# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker::settings {
    include ::config
    include users::builder
    include python3::settings

    $root                                = $config::scriptworker_root

    $_env_configs = {
        'dep' => {
            worker_group             => 'dep-pushapk',
            worker_type              => 'dep-pushapk',
            verbose_logging          => true,
            taskcluster_client_id    => secret('pushapk_scriptworker_taskcluster_client_id_dep'),
            taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_dep'),
            scope_prefixes           => ['project:releng:googleplay:'],
            cot_product              => 'firefox',
            github_oauth_token       => '',

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
            scope_prefixes           => ['project:releng:googleplay:'],
            cot_product              => 'firefox',
            github_oauth_token       => '',

            sign_chain_of_trust      => true,
            verify_chain_of_trust    => true,
            verify_cot_signature     => true,
        },
        'mobile-dep' => {
            worker_group             => 'mobile-pushapk-dep-v1',
            worker_type              => 'mobile-pushapk-dep-v1',
            verbose_logging          => true,
            # TODO: simplify client_id to not include project ("focus")
            taskcluster_client_id    => 'project/mobile/focus/releng/scriptworker/pushapk/dep',
            taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_mobile_dep'),
            scope_prefixes           => ['project:mobile:focus:releng:googleplay:product:', 'project:mobile:reference-browser:releng:googleplay:product:', 'project:mobile:fenix:releng:googleplay:product:'],
            cot_product              => 'mobile',
            github_oauth_token       => secret('scriptworker_github_oauth_token_staging'),

            sign_chain_of_trust      => false,
            verify_chain_of_trust    => true,
            verify_cot_signature     => false,
        },
        'mobile-prod' => {
            worker_group             => 'mobile-pushapk-v1',
            worker_type              => 'mobile-pushapk-v1',
            verbose_logging          => true,
            # TODO: simplify client_id to not include project ("focus")
            taskcluster_client_id    => 'project/mobile/focus/releng/scriptworker/pushapk/production',
            taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_mobile'),
            scope_prefixes           => ['project:mobile:focus:releng:googleplay:product:', 'project:mobile:reference-browser:releng:googleplay:product:', 'project:mobile:fenix:releng:googleplay:product:'],
            cot_product              => 'mobile',
            github_oauth_token       => secret('scriptworker_github_oauth_token_production'),

            sign_chain_of_trust      => true,
            verify_chain_of_trust    => true,
            verify_cot_signature     => true,
        },
    }

    $_env_config                         = $_env_configs[$pushapk_scriptworker_env]
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
    $github_oauth_token                  = $_env_config['github_oauth_token']

    $_google_play_all_accounts           = hiera_hash('pushapk_scriptworker_google_play_accounts')
    $_google_play_accounts               = $_google_play_all_accounts[$fqdn]

    # TODO: Replace this cumbersome logic by an `each` loop once we switch to Puppet 4
    case $pushapk_scriptworker_env {
        'dep': {
            $google_play_config = {
                'dep'  => {
                    service_account             => 'dummy',
                    certificate                 => 'dummy',
                    certificate_target_location => "${root}/dep.p12",
                },
            }
            $product_config = {
                'dep' => {
                    'has_nightly_track' => false,
                    'service_account' => $google_play_config['dep']['service_account'],
                    'certificate' => $google_play_config['dep']['certificate_target_location'],
                    'update_google_play_strings' => true,
                    'digest_algorithm' => 'SHA1',
                    'skip_check_package_names' => true,
                }
            }
            $jarsigner_certificate_aliases_content = {
                'dep' => 'dep',
            }
            $do_not_contact_google_play = true
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
            $product_config = {
              'aurora' => {
                  'has_nightly_track' => false,
                  'service_account' => $google_play_config['aurora']['service_account'],
                  'certificate' => $google_play_config['aurora']['certificate_target_location'],
                  'update_google_play_strings' => true,
                  'digest_algorithm' => 'SHA1',
                  'expected_package_names' => ['org.mozilla.fennec_aurora'],
              },
              'beta' => {
                  'has_nightly_track' => false,
                  'service_account' => $google_play_config['beta']['service_account'],
                  'certificate' => $google_play_config['beta']['certificate_target_location'],
                  'update_google_play_strings' => true,
                  'digest_algorithm' => 'SHA1',
                  'expected_package_names' => ['org.mozilla.firefox_beta'],
              },
              'release' => {
                  'has_nightly_track' => false,
                  'service_account' => $google_play_config['release']['service_account'],
                  'certificate' => $google_play_config['release']['certificate_target_location'],
                  'update_google_play_strings' => true,
                  'digest_algorithm' => 'SHA1',
                  'expected_package_names' => ['org.mozilla.firefox'],
              },
            }
            $jarsigner_certificate_aliases_content = {
              'aurora'  => 'nightly',
              'beta'    => 'release',
              'release' => 'release',
            }
            $do_not_contact_google_play = false
        }
        'mobile-dep': {
            $google_play_config = {
                'fenix'              => {
                    service_account             => 'dummy',
                    certificate                 => 'dummy',
                    certificate_target_location => "${root}/fenix.p12",
                },
                'focus'              => {
                    service_account             => 'dummy',
                    certificate                 => 'dummy',
                    certificate_target_location => "${root}/focus.p12",
                },
                'reference-browser'  => {
                    service_account             => 'dummy',
                    certificate                 => 'dummy',
                    certificate_target_location => "${root}/reference_browser.p12",
                },
            }
            $product_config = {
                'fenix'             => {
                    'has_nightly_track' => true,
                    'service_account' => $google_play_config['fenix']['service_account'],
                    'certificate' => $google_play_config['fenix']['certificate_target_location'],
                    'update_google_play_strings' => false,
                    'digest_algorithm' => 'SHA-256',
                    'expected_package_names' => ['org.mozilla.fenix'],
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                },
                'focus'             => {
                    'has_nightly_track' => true,
                    'service_account' => $google_play_config['focus']['service_account'],
                    'certificate' => $google_play_config['focus']['certificate_target_location'],
                    'update_google_play_strings' => false,
                    'digest_algorithm' => 'SHA-256',
                    'expected_package_names' => ['org.mozilla.focus', 'org.mozilla.klar'],
                    'skip_check_ordered_version_codes' => true,
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_check_same_package_name' => true,
                    'skip_checks_fennec' => true,
                },
                'reference-browser' => {
                    'has_nightly_track' => true,
                    'service_account' => $google_play_config['reference-browser']['service_account'],
                    'certificate' => $google_play_config['reference-browser']['certificate_target_location'],
                    'update_google_play_strings' => false,
                    'digest_algorithm' => 'SHA-256',
                    'expected_package_names' => ['org.mozilla.reference.browser'],
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                },
            }
            $jarsigner_certificate_aliases_content = {
                'fenix' => 'fenix',
                'focus' => 'focus',
                'reference-browser' => 'reference-browser',
            }
            $do_not_contact_google_play = true
        }
        'mobile-prod': {
            $google_play_config = {
                'fenix' => {
                    service_account             => $_google_play_accounts['fenix']['service_account'],
                    certificate                 => $_google_play_accounts['fenix']['certificate'],
                    certificate_target_location => "${root}/fenix.p12",
                },
                'focus'  => {
                    service_account             => $_google_play_accounts['focus']['service_account'],
                    certificate                 => $_google_play_accounts['focus']['certificate'],
                    certificate_target_location => "${root}/focus.p12",
                },
                'reference-browser' => {
                    service_account             => $_google_play_accounts['reference_browser']['service_account'],
                    certificate                 => $_google_play_accounts['reference_browser']['certificate'],
                    certificate_target_location => "${root}/reference_browser.p12",
                },
            }
            $product_config = {
                'fenix'             => {
                    'has_nightly_track' => true,
                    'service_account' => $google_play_config['fenix']['service_account'],
                    'certificate' => $google_play_config['fenix']['certificate_target_location'],
                    'update_google_play_strings' => false,
                    'digest_algorithm' => 'SHA-256',
                    'expected_package_names' => ['org.mozilla.fenix'],
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                },
                'focus' => {
                    'has_nightly_track' => true,
                    'service_account' => $google_play_config['focus']['service_account'],
                    'certificate' => $google_play_config['focus']['certificate_target_location'],
                    'update_google_play_strings' => false,
                    'digest_algorithm' => 'SHA-256',
                    'expected_package_names' => ['org.mozilla.focus', 'org.mozilla.klar'],
                    'skip_check_ordered_version_codes' => true,
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_check_same_package_name' => true,
                    'skip_checks_fennec' => true,
                },
                'reference-browser' => {
                    'has_nightly_track' => true,
                    'service_account' => $google_play_config['reference-browser']['service_account'],
                    'certificate' => $google_play_config['reference-browser']['certificate_target_location'],
                    'update_google_play_strings' => false,
                    'digest_algorithm' => 'SHA-256',
                    'expected_package_names' => ['org.mozilla.reference.browser'],
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                },
            }
            $jarsigner_certificate_aliases_content = {
                'fenix' => 'fenix',
                'focus' => 'focus',
                'reference-browser' => 'reference-browser'
            }
            $do_not_contact_google_play = false
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }

    $jarsigner_keystore                  = "${root}/mozilla-android-keystore"
    $jarsigner_keystore_password         = secret('pushapk_scriptworker_jarsigner_keystore_password')

    $jarsigner_all_certificates = {
        'nightly'                   => "${root}/nightly.cer",
        'release'                   => "${root}/release.cer",
        'dep'                       => "${root}/dep.cer",
        'fenix-dep'                 => "${root}/fenix_dep.cer",
        'fenix-release'             => "${root}/fenix_release.cer",
        'focus-dep'                 => "${root}/focus_dep.cer",
        'focus-release'             => "${root}/focus_release.cer",
        'reference-browser-dep'     => "${root}/reference_browser_dep.cer",
        'reference-browser-release' => "${root}/reference_browser_release.cer",
    }

    $verbose_logging                     = $_env_config['verbose_logging']

    $script_config                       = "${root}/script_config.json"
    $script_config_content = {
        'work_dir'   => $work_dir,
        'verbose'    => $verbose_logging,

        # TODO after releng RFC #6 is merged, 'google_play_accounts' is no longer needed
        'google_play_accounts' => $product_config,
        'products' => $product_config,
        'jarsigner_key_store' => $jarsigner_keystore,
        'jarsigner_certificate_aliases' => $jarsigner_certificate_aliases_content,

        'taskcluster_scope_prefixes' => $_env_config['scope_prefixes'],
        'do_not_contact_google_play' => $do_not_contact_google_play,
    }
}
