# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pushapk_scriptworker::jarsigner_init {
    include ::config
    include packages::jdk17

    $nightly = $pushapk_scriptworker::settings::jarsigner_nightly_certificate
    $release = $pushapk_scriptworker::settings::jarsigner_release_certificate

    File {
      ensure      => 'present',
      show_diff   => false,
    }

    file {
        $nightly:
            content     => secret('pushapk_scriptworker_nightly_jarsigner_certificate');

        $release:
            content     => secret('pushapk_scriptworker_release_jarsigner_certificate');
    }

    Java_ks {
      ensure       => latest,
      target       => $pushapk_scriptworker::settings::jarsigner_keystore,
      password     => $pushapk_scriptworker::settings::jarsigner_keystore_password,
      trustcacerts => true,
    }

    java_ks {
        $pushapk_scriptworker::settings::jarsigner_nightly_certificate_alias:
            certificate  => $nightly;

        $pushapk_scriptworker::settings::jarsigner_release_certificate_alias:
            certificate  => $release;
    }
}
