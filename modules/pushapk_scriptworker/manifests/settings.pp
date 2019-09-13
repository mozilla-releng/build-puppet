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
            scope_prefixes           => ['project:mobile:focus:releng:googleplay:product:', 'project:mobile:reference-browser:releng:googleplay:product:', 'project:mobile:fenix:releng:googleplay:product:', 'project:mobile:firefox-tv:releng:googleplay:product:'],
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
            scope_prefixes           => ['project:mobile:focus:releng:googleplay:product:', 'project:mobile:reference-browser:releng:googleplay:product:', 'project:mobile:fenix:releng:googleplay:product:', 'project:mobile:firefox-tv:releng:googleplay:product:'],
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
    $google_play_accounts                = $_google_play_all_accounts[$fqdn]

    # TODO: Replace this cumbersome logic by an `each` loop once we switch to Puppet 4
    case $pushapk_scriptworker_env {
        'dep': {
            $product_config = [
                {
                    'product_names' => ['dep'],
                    'digest_algorithm' => 'SHA1',
                    'override_channel_model' => 'choose_google_app_with_scope',
                    'apps' => {
                        'dep' => {
                            'package_names' => ['org.mozilla.fennec_aurora'],
                            'default_track' => 'beta',
                            'service_account' => 'dummy',
                            'credentials_file' => "${root}/dep.p12",
                            'certificate_alias' => 'dep',
                        }
                    }
                }
            ]
            $do_not_contact_server = true
        }
        'prod': {
            $product_config = [
                {
                    'product_names' => ['aurora', 'beta', 'release'],
                    'digest_algorithm' => 'SHA1',
                    'override_channel_model' => 'choose_google_app_with_scope',
                    'apps' => {
                        'aurora' => {
                            'package_names' => ['org.mozilla.fennec_aurora'],
                            'default_track' => 'beta',
                            'service_account' => $google_play_accounts['aurora']['service_account'],
                            'credentials_file' => "${root}/aurora.p12",
                            'certificate_alias' => 'nightly',
                        },
                        'beta' => {
                            'package_names' => ['org.mozilla.firefox_beta'],
                            'default_track' => 'production',
                            'service_account' => $google_play_accounts['beta']['service_account'],
                            'credentials_file' => "${root}/beta.p12",
                            'certificate_alias' => 'release',
                        },
                        'release' => {
                            'package_names' => ['org.mozilla.firefox'],
                            'default_track' => 'production',
                            'service_account' => $google_play_accounts['release']['service_account'],
                            'credentials_file' => "${root}/release.p12",
                            'certificate_alias' => 'release',
                        },
                    }
                },
            ]
            $do_not_contact_server = false
        }
        'mobile-dep': {
            $product_config = [
                {
                    'product_names' => ['fenix'],
                    'digest_algorithm' => 'SHA-256',
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'override_channel_model' => 'single_google_app',
                    'app' => {
                        'package_names' => ['org.mozilla.fenix', 'org.mozilla.fenix.beta', 'org.mozilla.fenix.nightly'],
                        'service_account' => 'dummy',
                        'credentials_file' => "${root}/fenix.p12",
                        'certificate_alias' => 'fenix',
                    }
                },
                {
                    'product_names' => ['focus'],
                    'digest_algorithm' => 'SHA-256',
                    'skip_check_ordered_version_codes' => true,
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'override_channel_model' => 'single_google_app',
                    'app' => {
                        'package_names' => ['org.mozilla.focus', 'org.mozilla.klar'],
                        'service_account' => 'dummy',
                        'credentials_file' => "${root}/focus.p12",
                        'certificate_alias' => 'focus',
                    }
                },
                {
                    'product_names' => ['reference-browser'],
                    'digest_algorithm' => 'SHA-256',
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'override_channel_model' => 'single_google_app',
                    'app' => {
                        'package_names' => ['org.mozilla.reference.browser'],
                        'service_account' => 'dummy',
                        'credentials_file' => "${root}/reference_browser.p12",
                        'certificate_alias' => 'reference-browser',
                    }
                },
                {
                    'product-names' => ['firefox-tv'],
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'skip_check_signature' => true,
                    'apps' => {
                        'dep' => {
                            'package_names' => ['org.mozilla.video.firefox'],
                            'amazon' => {
                                'client_id' => 'dummy',
                                'client_secret' => 'dummy'
                            }
                        },
                    }
                },
            ]
            $do_not_contact_server = true
        }
        'mobile-prod': {
            $product_config = [
                {
                    'product_names' => ['fenix'],
                    'digest_algorithm' => 'SHA-256',
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'apps' => {
                        'nightly' => {
                            'package_names' => ['org.mozilla.fenix.nightly'],
                            'certificate_alias' => 'fenix-nightly',
                            'google' => {
                                'default_track' => 'beta',
                                'service_account' => $google_play_accounts['fenix-nightly']['service_account'],
                                'credentials_file' => "${root}/fenix_nightly.p12",
                            }
                        },
                        'beta' => {
                            'package_names' => ['org.mozilla.fenix.beta'],
                            'certificate_alias' => 'fenix-beta',
                            'google' => {
                                'default_track' => 'internal',
                                'service_account' => $google_play_accounts['fenix-beta']['service_account'],
                                'credentials_file' => "${root}/fenix_beta.p12",
                            }
                        },
                        'production' => {
                            'package_names' => ['org.mozilla.fenix'],
                            'certificate_alias' => 'fenix-production',
                            'google' => {
                                'default_track' => 'internal',
                                'service_account' => $google_play_accounts['fenix-production']['service_account'],
                                'credentials_file' => "${root}/fenix_production.p12",
                            }
                        },
                    }
                },
                {
                    'product_names' => ['focus'],
                    'digest_algorithm' => 'SHA-256',
                    'skip_check_ordered_version_codes' => true,
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'override_channel_model' => 'single_google_app',
                    'app' => {
                        'service_account' => $google_play_accounts['focus']['service_account'],
                        'credentials_file' => "${root}/focus.p12",
                        'package_names' => ['org.mozilla.focus', 'org.mozilla.klar'],
                        'certificate_alias' => 'focus',
                    }
                },
                {
                    'product_names' => ['reference-browser'],
                    'digest_algorithm' => 'SHA-256',
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'override_channel_model' => 'single_google_app',
                    'app' => {
                        'service_account' => $google_play_accounts['reference_browser']['service_account'],
                        'credentials_file' => "${root}/reference_browser.p12",
                        'package_names' => ['org.mozilla.reference.browser'],
                        'certificate_alias' => 'reference-browser',
                    }
                },
                {
                    'product-names' => ['firefox-tv'],
                    'skip_check_multiple_locales' => true,
                    'skip_check_same_locales' => true,
                    'skip_checks_fennec' => true,
                    'skip_check_signature' => true,
                    'apps' => {
                        'production' => {
                            'package_names' => ['org.mozilla.video.firefox'],
                            'amazon' => {
                                'client_id' => $google_play_accounts['firefox_tv-production']['client_id'],
                                'client_secret' => $google_play_accounts['firefox_tv-production']['client_secret']
                            }
                        },
                    }
                },
            ]
            $do_not_contact_server = false
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }

    $jarsigner_keystore                  = "${root}/mozilla-android-keystore"
    $jarsigner_keystore_password         = secret('pushapk_scriptworker_jarsigner_keystore_password')

    $verbose_logging                     = $_env_config['verbose_logging']

    $script_config                       = "${root}/script_config.json"
    $script_config_content = {
        'work_dir'   => $work_dir,
        'verbose'    => $verbose_logging,

        'products' => $product_config,
        'jarsigner_key_store' => $jarsigner_keystore,

        'taskcluster_scope_prefixes' => $_env_config['scope_prefixes'],
        'do_not_contact_server' => $do_not_contact_server,
    }
}
