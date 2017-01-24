class pushapkworker::jarsigner_init {
    include ::config
    include packages::jdk17

    $nightly = $pushapkworker::settings::jarsigner_nightly_certificate
    $release = $pushapkworker::settings::jarsigner_release_certificate

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
      target       => $pushapkworker::settings::jarsigner_keystore,
      password     => $pushapkworker::settings::jarsigner_keystore_password,
      trustcacerts => true,
    }

    java_ks {
        $pushapkworker::settings::jarsigner_nightly_certificate_alias:
            certificate  => $nightly;

        $pushapkworker::settings::jarsigner_release_certificate_alias:
            certificate  => $release;
    }
}
