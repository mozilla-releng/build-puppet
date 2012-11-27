class mozpool::settings {
    include config::secrets

    $root = "/opt/mozpool"
    $config_ini = "${root}/config.ini"

    if ($mozpool_staging) {
        $db_database = $::config::secrets::mozpool_staging_db_database
        $db_username = $::config::secrets::mozpool_staging_db_username
        $db_password = $::config::secrets::mozpool_staging_db_password
        $db_hostname = $::config::secrets::mozpool_staging_db_hostname
    } else {
        $db_database = $::config::secrets::mozpool_db_database
        $db_username = $::config::secrets::mozpool_db_username
        $db_password = $::config::secrets::mozpool_db_password
        $db_hostname = $::config::secrets::mozpool_db_hostname
    }
}
