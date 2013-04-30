# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool::settings {
    include config::secrets

    $root = "/opt/mozpool"
    $config_ini = "${root}/config.ini"

    if ($mozpool_staging) {
        $db_database = $::config::secrets::mozpool_staging_db_database
        $db_username = $::config::secrets::mozpool_staging_db_username
        $db_password = $::config::secrets::mozpool_staging_db_password
        $db_hostname = $::config::secrets::mozpool_staging_db_hostname
        $mozpool_version = "4.0.0"
    } else {
        $db_database = $::config::secrets::mozpool_db_database
        $db_username = $::config::secrets::mozpool_db_username
        $db_password = $::config::secrets::mozpool_db_password
        $db_hostname = $::config::secrets::mozpool_db_hostname
        $mozpool_version = "3.0.1"
    }
}
