# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class aws_manager::settings {
    include ::config

    $root = $::config::aws_manager_root
    $cloud_tools_dst = "${root}/cloud-tools"
    $secrets_dir = "${root}/secrets"
    $cloudtrail_logs_dir = "${root}/cloudtrail_logs"
    $events_dir= "${cloudtrail_logs_dir}/events"

    $cron_switch = $fqdn ? {
        $config::distinguished_aws_manager => present,
        default => absent,
    }
}
