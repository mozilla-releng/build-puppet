# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool::settings {
    $root = "/opt/mozpool"
    $config_ini = "${root}/config.ini"

    # allow different versions in staging and prod
    if (has_aspect("staging")) {
        $mozpool_version = "4.2.1"
    } else {
        $mozpool_version = "4.2.0"
    }

    $db_database = secret("mozpool_db_database")
    $db_username = secret("mozpool_db_username")
    $db_password = secret("mozpool_db_password")
    $db_hostname = secret("mozpool_db_hostname")
}
