class pushapkworker::jarsigner_init {
    include ::config
    include packages::jdk17

    $nightly = "${pushapkworker::settings::root}/nightly.cer"
    $release = "${pushapkworker::settings::root}/release.cer"

    file {
        $nightly:
            ensure      => 'present',
            content     => secret('pushapk_scriptworker_nightly_jarsigner_certificate'),
            show_diff   => false;

        $release:
            ensure      => 'present',
            content     => secret('pushapk_scriptworker_release_jarsigner_certificate'),
            show_diff   => false;
    }

    java_ks {
        $config::pushapk_scriptworker_jarsigner_nightly_certificate_alias:
            ensure       => latest,
            certificate  => $nightly,
            target       => $config::pushapk_scriptworker_jarsigner_keystore,
            password     => secret('pushapk_scriptworker_jarsigner_keystore_password'),
            trustcacerts => true;

        $config::pushapk_scriptworker_jarsigner_release_certificate_alias:
            ensure       => latest,
            certificate  => $release,
            target       => $config::pushapk_scriptworker_jarsigner_keystore,
            password     => secret('pushapk_scriptworker_jarsigner_keystore_password'),
            trustcacerts => true;
    }
}
