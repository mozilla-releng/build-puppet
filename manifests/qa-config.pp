# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "qa"

    $puppet_notif_email = "hskupin@mozilla.com"
    $puppet_server_reports = "tagmail"
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
    $puppet_again_repo = "https://hg.mozilla.org/qa/puppet/"

    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppetmaster_public_mirror_hosts = [ ]

    $ntp_server = "ns1.private.scl3.mozilla.com"

    $web_proxy_url = "http://proxy.dmz.scl3.mozilla.com:3128/"
    $web_proxy_exceptions = ['localhost', '127.0.0.1', 'localaddress',
                             '.localdomain.com', '10.0.0.0/8',
                             '.scl3.mozilla.com', '.phx1.mozilla.com', '.mozqa.com',
                             'mm-ci-master', 'mm-ci-staging', 'db1',
                             'puppet', 'repos']

    $vmwaretools_version = "9.4.0-1280544"
    $vmwaretools_md5 = "4a2d230828919048c0c3ae8420f8edfe"

    $admin_users = [
        'cknowles',
        'dmitchell',
        'gcox',
        'afernandez',
        'bpannabecker',
        'eziegenhorn',
        'lhirlimann',
        'pradcliffe',
        'rbryce',
        'rwatson',
        'shyam',

        # Admins of the QA org
        "aeftimie",
        "amatei",
        "ctalbert",
        "hskupin"
    ]
}

