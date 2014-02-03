# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "qa"

    $puppet_notif_email = "dustin@mozilla.com"
    $puppet_server_reports = ""
    $builder_username = "qabld"
    $grouped_puppet_servers = {
        ".*" => [
            "puppetmaster1.qa.scl3.mozilla.com",
        ],
    }
    $puppet_servers = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server

    $distinguished_puppetmaster = "puppetmaster1.qa.scl3.mozilla.com"
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet/"

    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppetmaster_upstream_rsync_args = '--exclude=repos/apt'
    $puppetmaster_public_mirror_hosts = [ ]

    $ntp_server = "ns1.private.scl3.mozilla.com"
    $web_proxy_url = "http://proxy.dmz.scl3.mozilla.com:3128/"
    $web_proxy_exceptions = ['localhost', '127.0.0.1', 'localaddress', '.localdomain.com',
                             '10.0.0.0/8', '.scl3.mozilla.com', '.phx1.mozilla.com']

    $admin_users = [
        "dmitchell",
        "hskupin",
        "dhunt",
        "rwood",
        "ctalbert",
    ]
}

