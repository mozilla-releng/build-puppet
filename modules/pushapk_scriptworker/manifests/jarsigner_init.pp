# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker::jarsigner_init {
    include ::config
    include packages::jdk17

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
            $dep = $pushapk_scriptworker::settings::jarsigner_all_certificates['dep']
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
            $nightly = $pushapk_scriptworker::settings::jarsigner_all_certificates['nightly']
            $release = $pushapk_scriptworker::settings::jarsigner_all_certificates['release']

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
            $fenix = $pushapk_scriptworker::settings::jarsigner_all_certificates['fenix-dep']
            $focus = $pushapk_scriptworker::settings::jarsigner_all_certificates['focus-dep']
            $reference_browser = $pushapk_scriptworker::settings::jarsigner_all_certificates['reference-browser-dep']

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
            $fenix = $pushapk_scriptworker::settings::jarsigner_all_certificates['fenix-release']
            $focus = $pushapk_scriptworker::settings::jarsigner_all_certificates['focus-release']
            $reference_browser = $pushapk_scriptworker::settings::jarsigner_all_certificates['reference-browser-release']

            file {
                $fenix:
                    source => 'puppet:///modules/pushapk_scriptworker/fenix_release.pem';
                $focus:
                    source => 'puppet:///modules/pushapk_scriptworker/focus_release.pem';
                $reference_browser:
                    source => 'puppet:///modules/pushapk_scriptworker/reference_browser_release.pem';
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
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }
}
