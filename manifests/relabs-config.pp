# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "relabs"

    $puppet_notif_email = "dustin@mozilla.com"
    $puppet_server_reports = ""
    $builder_username = "relabsbld"
    $grouped_puppet_servers = {
        ".*" => [
            "relabs03.build.mtv1.mozilla.com",
        ],
    }
    $puppet_servers = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server

    $distinguished_puppetmaster = "relabs03.build.mtv1.mozilla.com"
    $puppet_again_repo = "http://hg.mozilla.org/build/puppet/"

    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppetmaster_upstream_rsync_args = '--exclude=repos/apt'
    $puppetmaster_public_mirror_hosts = [ ]

    $signer_username = 'relabssign'
    $signing_tools_repo = 'http://hg.mozilla.org/build/tools'
    $signing_redis_host = 'localhost'
    $signing_mac_id = 'Relabs'
    $signing_allowed_ips = [
        '10.250.48.0/22',
        '10.26.78.0/24',
    ]
    $signing_new_token_allowed_ips = [
        '10.250.48.1', # fake
    ]

    $ntp_server = "ntp.build.mozilla.org"
    $admin_users = [
        "arr",
        "bhearsum",
        "catlee",
        "dmitchell",
        "jwatkins",
        "jwood",
        "raliiev",
    ]
}

