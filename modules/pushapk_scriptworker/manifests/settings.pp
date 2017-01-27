class pushapk_scriptworker::settings {
    include ::config
    include users::builder

    $root = $config::scriptworker_root

    $_env_configs = {
      'dev' => {
        worker_group => 'pushapk-v1-dev',
        worker_type => 'pushapk-v1-dev',
        verbose_logging => true,
        taskcluster_client_id => secret('pushapk_scriptworker_taskcluster_client_id_dev'),
        taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_dev'),
        google_play_config => {
          'aurora' => {
            service_account => secret('pushapk_scriptworker_aurora_google_play_service_account_dev'),
            certificate => secret('pushapk_scriptworker_aurora_google_play_certificate_dev'),
            certificate_target_location => "${root}/aurora.p12",
          },
          'beta' => {
            service_account => secret('pushapk_scriptworker_beta_google_play_service_account_dev'),
            certificate => secret('pushapk_scriptworker_beta_google_play_certificate_dev'),
            certificate_target_location => "${root}/beta.p12",
          },
          'release' => {
            service_account => secret('pushapk_scriptworker_release_google_play_service_account_dev'),
            certificate => secret('pushapk_scriptworker_release_google_play_certificate_dev'),
            certificate_target_location => "${root}/release.p12",
          },
        },
      },
      'prod' => {
        worker_group => 'pushapk-v1',
        worker_type => 'pushapk-v1',
        verbose_logging => true,
        taskcluster_client_id => secret('pushapk_scriptworker_taskcluster_client_id_prod'),
        taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_prod'),
        google_play_config => {
          'aurora' => {
            service_account => secret('pushapk_scriptworker_aurora_google_play_service_account_prod'),
            certificate => secret('pushapk_scriptworker_aurora_google_play_certificate_prod'),
            certificate_target_location => "${root}/aurora.p12",
          },
          'beta' => {
            service_account => secret('pushapk_scriptworker_beta_google_play_service_account_prod'),
            certificate => secret('pushapk_scriptworker_beta_google_play_certificate_prod'),
            certificate_target_location => "${root}/beta.p12",
          },
          'release' => {
            service_account => secret('pushapk_scriptworker_release_google_play_service_account_prod'),
            certificate => secret('pushapk_scriptworker_release_google_play_certificate_prod'),
            certificate_target_location => "${root}/release.p12",
          },
        },
      },
    }

    $_env_config = $_env_configs[$pushapk_scriptworker_env]
    $schema_file = "${root}/lib/python3.5/site-packages/pushapkscript/data/pushapk_task_schema.json"
    $work_dir = "${root}/work"
    $script_config = "${root}/script_config.json"
    $task_script = "${root}/bin/pushapkscript"

    $user = $users::builder::username
    $group = $users::builder::group

    $taskcluster_client_id = $_env_config['taskcluster_client_id']
    $taskcluster_access_token = $_env_config['taskcluster_access_token']
    $worker_group = $_env_config['worker_group']
    $worker_type = $_env_config['worker_type']

    $google_play_config = $_env_config['google_play_config']

    $jarsigner_keystore = "${root}/mozilla-android-keystore"
    $jarsigner_keystore_password = secret('pushapk_scriptworker_jarsigner_keystore_password')

    $jarsigner_nightly_certificate = "${root}/nightly.cer"
    $jarsigner_nightly_certificate_alias = 'nightly'

    $jarsigner_release_certificate = "${root}/release.cer"
    $jarsigner_release_certificate_alias = 'release'

    $verbose_logging = $_env_config['verbose_logging']

}
