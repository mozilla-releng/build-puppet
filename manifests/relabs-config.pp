# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "relabs"

    $puppet_notif_email = "dustin@mozilla.com"
    $builder_username = "relabsbld"
    $grouped_puppet_servers = {
        ".*" => [
            "relabs-puppet2.relabs.releng.scl3.mozilla.com",
        ],
    }
    $puppet_servers = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server
    $apt_repo_server = $data_server

    $distinguished_puppetmaster = "relabs-puppet2.relabs.releng.scl3.mozilla.com"
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet/"

    $puppet_server_reports = "http"
    $puppet_server_reporturl = "http://foreman.pvt.build.mozilla.org:3001/"
    $puppet_server_facturl = "http://foreman.pvt.build.mozilla.org:3000/"
    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppetmaster_public_mirror_hosts = [ ]
    $puppetmaster_extsyncs = {
        'slavealloc' => {
            'slavealloc_api_url' => 'http://slavealloc.pvt.build.mozilla.org/api/',
        },
    }

    $signer_username = 'relabssign'
    $signing_tools_repo = 'https://hg.mozilla.org/build/tools'
    $signing_redis_host = 'localhost'
    $signing_mac_id = 'Relabs'
    $signing_allowed_ips = [
        '10.250.48.0/22',
        '10.26.78.0/24',
    ]
    $signing_new_token_allowed_ips = [
        '10.250.48.1', # fake
    ]

    $vmwaretools_version = "9.4.0-1280544"
    $vmwaretools_md5 = "4a2d230828919048c0c3ae8420f8edfe"

    $ntp_server = "time.mozilla.org"
    $admin_users = [
        "arr",
        "bhearsum",
        "catlee",
        "dmitchell",
        "jwatkins",
        "jwood",
        "raliiev",
        "cknowles",
        "dmaher",
        "hskupin",
        "pchiasson",
        "tglek",
        "jvehent",
    ]
}

