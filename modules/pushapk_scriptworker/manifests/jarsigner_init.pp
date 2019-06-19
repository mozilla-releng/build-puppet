# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker::jarsigner_init {
    include ::config
    include packages::jdk17

    $root = $config::scriptworker_root

    File {
        ensure    => 'present',
        show_diff => false,
    }

    Java_ks {
        ensure       => latest,
        target       => $pushapk_scriptworker::settings::jarsigner_keystore,
        password     => $pushapk_scriptworker::settings::jarsigner_keystore_password,
        trustcacerts => true,
    }

    case $pushapk_scriptworker_env {
        'dep': {
            $dep = "${root}/dep.cer"
            file {
                $dep:
                    source => 'puppet:///modules/pushapk_scriptworker/dep.pem';
            }

            java_ks {
                'dep':
                    certificate  => $dep;
            }
        }
        'prod': {
            $nightly = "${root}/nightly.cer"
            $release = "${root}/release.cer"

            file {
                $nightly:
                    source => 'puppet:///modules/pushapk_scriptworker/nightly.pem';

                $release:
                    source => 'puppet:///modules/pushapk_scriptworker/release.pem';
            }

            java_ks {
                'nightly':
                    certificate  => $nightly;

                'release':
                    certificate  => $release;
            }
        }
        'mobile-dep': {
            $fenix = "${root}/fenix_dep.cer"
            $focus = "${root}/focus_dep.cer"
            $reference_browser = "${root}/reference_browser_dep.cer"

            file {
                $fenix:
                    source => 'puppet:///modules/pushapk_scriptworker/fenix_dep.pem';
                $focus:
                    source => 'puppet:///modules/pushapk_scriptworker/focus_dep.pem';
                $reference_browser:
                    source => 'puppet:///modules/pushapk_scriptworker/reference_browser_dep.pem';
            }

            java_ks {
                'fenix':
                    certificate => $fenix;
                'focus':
                    certificate => $focus;
                'reference-browser':
                    certificate => $reference_browser;
            }
        }
        'mobile-prod': {
            $fenix_nightly = "${root}/fenix_nightly.cer"
            $fenix_beta = "${root}/fenix_beta.cer"
            $fenix_production = "${root}/fenix_production.cer"
            $focus = "${root}/focus_release.cer"
            $reference_browser = "${root}/reference_browser_release.cer"

            file {
                $fenix_nightly:
                    source => 'puppet:///modules/pushapk_scriptworker/fenix_nightly.pem';
                $fenix_beta:
                    source => 'puppet:///modules/pushapk_scriptworker/fenix_beta.pem';
                $fenix_production:
                    source => 'puppet:///modules/pushapk_scriptworker/fenix_production.pem';
                $focus:
                    source => 'puppet:///modules/pushapk_scriptworker/focus_release.pem';
                $reference_browser:
                    source => 'puppet:///modules/pushapk_scriptworker/reference_browser_release.pem';
            }

            java_ks {
                'fenix-nightly':
                    certificate => $fenix_nightly;
                'fenix-beta':
                    certificate => $fenix_beta;
                'fenix-production':
                    certificate => $fenix_production;
                'focus':
                    certificate => $focus;
                'reference-browser':
                    certificate => $reference_browser;
            }
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }
}
