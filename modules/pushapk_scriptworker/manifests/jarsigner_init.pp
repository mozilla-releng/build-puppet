# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker::jarsigner_init {
    include ::config
    include packages::jdk17

    File {
      ensure      => 'present',
      show_diff   => false,
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
        'mobile-prod': {
            $focus = $pushapk_scriptworker::settings::jarsigner_all_certificates['focus']
            file {
                $focus:
                    source => 'puppet:///modules/pushapk_scriptworker/focus.pem';
            }

            java_ks {
                'focus':
                    certificate  => $focus;
            }
        }
        default: {
            fail("Invalid pushapk_scriptworker_env given: ${pushapk_scriptworker_env}")
        }
    }
}
