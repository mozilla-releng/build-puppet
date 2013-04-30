# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Secrets
# if you add a new key here, add it to the wiki as well!
class config::secrets {
    $root_pw_hash = extlookup("root_pw_hash")
    $root_pw_pbkdf2 = extlookup("root_pw_pbkdf2")
    $root_pw_pbkdf2_salt = extlookup("root_pw_pbkdf2_salt")
    $root_pw_pbkdf2_iterations = extlookup("root_pw_pbkdf2_iterations")
    $root_pw_saltedsha512 = extlookup("root_pw_saltedsha512")
    $builder_pw_hash = extlookup("builder_pw_hash")
    $builder_pw_pbkdf2 = extlookup("builder_pw_pbkdf2")
    $builder_pw_pbkdf2_salt = extlookup("builder_pw_pbkdf2_salt")
    $builder_pw_pbkdf2_iterations = extlookup("builder_pw_pbkdf2_iterations")
    $builder_pw_kcpassword_base64 = extlookup("builder_pw_kcpassword_base64")
    $builder_pw_vnc_base64 = extlookup("builder_pw_vnc_base64")
    $builder_pw_saltedsha512 = extlookup("builder_pw_saltedsha512")
    $bors_servo_gh_user = extlookup("bors_servo_gh_user")
    $bors_servo_gh_pass = extlookup("bors_servo_gh_pass")
    $mozpool_inventory_url = extlookup("mozpool_inventory_url")
    $mozpool_inventory_username = extlookup("mozpool_inventory_username")
    $mozpool_inventory_password = extlookup("mozpool_inventory_password")
    $mozpool_db_hostname = extlookup("mozpool_db_hostname")
    $mozpool_db_username = extlookup("mozpool_db_username")
    $mozpool_db_password = extlookup("mozpool_db_password")
    $mozpool_db_database = extlookup("mozpool_db_database")
    $mozpool_staging_db_hostname = extlookup("mozpool_staging_db_hostname")
    $mozpool_staging_db_username = extlookup("mozpool_staging_db_username")
    $mozpool_staging_db_password = extlookup("mozpool_staging_db_password")
    $mozpool_staging_db_database = extlookup("mozpool_staging_db_database")

    # biuldbot master secrets
    $buildbot_statusdb_username = extlookup("buildbot_statusdb_username")
    $buildbot_statusdb_hostname = extlookup("buildbot_statusdb_hostname")
    $buildbot_statusdb_password = extlookup("buildbot_statusdb_password")
    $buildbot_statusdb_database = extlookup("buildbot_statusdb_database")
    $buildbot_schedulerdb_username = extlookup("buildbot_schedulerdb_username")
    $buildbot_schedulerdb_hostname = extlookup("buildbot_schedulerdb_hostname")
    $buildbot_schedulerdb_password = extlookup("buildbot_schedulerdb_password")
    $buildbot_schedulerdb_database = extlookup("buildbot_schedulerdb_database")
    $pulse_exchange = extlookup("pulse_exchange")
    $pulse_password = extlookup("pulse_password")
    $pulse_username = extlookup("pulse_username")

    # BuildSlaves.py entries
    $try_build_password = extlookup("try_build_password")
    $prod_build_password = extlookup("prod_build_password")
    $tuxedo_username = extlookup("tuxedo_username")
    $tuxedo_password = extlookup("tuxedo_password")
    $balrog_username = extlookup("balrog_username")
    $balrog_password = extlookup("balrog_password")
    $linux_tests_password = extlookup("linux_tests_password")
    $mac_tests_password = extlookup("mac_tests_password")
    $win_tests_password = extlookup("win_tests_password")
    $android_tests_password = extlookup("android_tests_password")
    $talos_oauth_key = extlookup("talos_oauth_key")
    $talos_oauth_secret = extlookup("talos_oauth_secret")
    $jetperf_oauth_key = extlookup("jetperf_oauth_key")
    $jetperf_oauth_secret = extlookup("jetperf_oauth_secret")

    # passwords.py
    $signing_server_username = extlookup("signing_server_username")
    $signing_server_nightly_password = extlookup("signing_server_nightly_password")
    $signing_server_dep_password = extlookup("signing_server_dep_password")
    $signing_server_release_password = extlookup("signing_server_release_password")
}
