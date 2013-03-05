# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class buildmaster::settings {
    include users::builder
    include config::secrets

    $master_root = "/builds/buildbot"
    $queue_dir = "${master_root}/queue"
    $buildbot_statusdb_username = $::config::secrets::buildbot_statusdb_username
    $buildbot_statusdb_hostname = $::config::secrets::buildbot_statusdb_hostname
    $buildbot_statusdb_password = $::config::secrets::buildbot_statusdb_password
    $buildbot_statusdb_database = $::config::secrets::buildbot_statusdb_database
    $buildbot_schedulerdb_username = $::config::secrets::buildbot_schedulerdb_username
    $buildbot_schedulerdb_hostname = $::config::secrets::buildbot_schedulerdb_hostname
    $buildbot_schedulerdb_password = $::config::secrets::buildbot_schedulerdb_password
    $buildbot_schedulerdb_database = $::config::secrets::buildbot_schedulerdb_database
    $pulse_exchange = $::config::secrets::pulse_exchange
    $pulse_password = $::config::secrets::pulse_password
    $pulse_username = $::config::secrets::pulse_username
    $buildmaster_secrets = $::config::secrets::buildmaster_secrets
    $lock_dir = "/var/lock/${users::builder::username}"
    $master_json = $::config::secrets::master_json
    $buildbot_tools_hg_repo = $::config::secrets::buildbot_tools_hg_repo
    $buildbot_configs_hg_repo = $::config::secrets::buildbot_configs_hg_repo
    $buildbot_mail_to= $::config::secrets::buildbot_mail_to
}
