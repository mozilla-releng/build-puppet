# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "moco"

    $puppet_notif_email = "releng-shared@mozilla.com"
    $puppet_server_reports = "tagmail,http"
    $puppet_server_reporturl = "http://puppetdash.pvt.build.mozilla.org/reports/upload"
    $builder_username = "cltbld"

    # we use the sort_servers_by_group function to sort the list of servers, and then just use
    # the first as the primary server
    $grouped_puppet_servers = {
        ".*\\.mtv1\\.mozilla\\.com" => [
           "releng-puppet2.build.mtv1.mozilla.com",
        ],
        ".*\\.scl1\\.mozilla\\.com" => [
           "releng-puppet2.build.scl1.mozilla.com",
        ],
        ".*\\.releng\\.scl3\\.mozilla\\.com" => [
           "releng-puppet2.srv.releng.scl3.mozilla.com",
        ],
        ".*\\.releng\\.(use1|aws-us-east-1)\\.mozilla\\.com" => [
            "releng-puppet1.srv.releng.use1.mozilla.com",
            "releng-puppet2.srv.releng.use1.mozilla.com",
        ],
        ".*\\.releng\\.(usw2|aws-us-west-2)\\.mozilla\\.com" => [
            "releng-puppet1.srv.releng.usw2.mozilla.com",
            "releng-puppet2.srv.releng.usw2.mozilla.com",
        ],
    }
    $puppet_servers = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server

    $distinguished_puppetmaster = "releng-puppet2.srv.releng.scl3.mozilla.com"
    $puppetmaster_public_mirror_hosts = [ "releng-puppet2.srv.releng.scl3.mozilla.com" ]
    $puppet_again_repo = "http://hg.mozilla.org/build/puppet/"

    $nrpe_allowed_hosts = "10.2.71.20,10.12.75.9,127.0.0.1,10.26.75.30"
    $ntp_server = "ntp.build.mozilla.org"

    $signer_username = 'cltsign'
    $signing_tools_repo = 'http://hg.mozilla.org/build/tools'
    $signing_redis_host = 'redis01.build.scl1.mozilla.com'
    $signing_mac_id = 'Mozilla'
    $signing_allowed_ips = [
        '10.12.40.0/22',
        '10.12.48.0/21',
        '10.26.36.0/22',
        '10.26.40.0/22',
        '10.26.48.0/24',
        '10.26.44.0/22',
        '10.26.52.0/22',
        '10.26.64.0/22',
        '10.134.52.0/23',
        '10.134.64.0/23',
        '10.134.48.0/23',
        '10.132.52.0/24',
        '10.132.53.0/24',
        '10.132.54.0/24',
        '10.132.64.0/24',
        '10.132.65.0/24',
        '10.132.48.0/24',
        '10.132.49.0/24',
        '10.132.50.0/24',
        '10.132.66.0/24',
        '10.250.48.0/22',
    ]
    $signing_new_token_allowed_ips = [
        '10.12.48.14',
        '10.132.49.112',
        '10.132.49.125',
        '10.132.50.44',
        '10.132.50.56',
        '10.132.50.142',
        '10.132.50.247',
        '10.134.48.196',
        '10.134.48.228',
        '10.134.48.236',
        '10.134.49.62',
        '10.134.49.93',
        '10.134.49.223',
    ]

    $admin_users = $fqdn ? {
        # signing machines have a very limited access list
        /^(mac-)?signing\d\..*/ => [
            # a few folks from relops..
            'arr',
            'dmitchell',
            'jwatkins',

            # ..and a few folks from releng
            'bhearsum',
            'catlee',
            'coop',
            'joduinn',
            'nthomas',
            'raliiev',
        ],
        default => [
            'achavez',
            'acoh',
            'adam',
            'afernandez',
            'ahill2',
            'aignacio',
            'amckay',
            'amilewski',
            'armenzg',
            'arr',
            'asasaki',
            'ashish',
            'bburton',
            'bhearsum',
            'bhourigan',
            'bjohnson',
            'bkero',
            'bobm',
            'catlee',
            'cbook',
            'ckolos',
            'cliang',
            'coop',
            'cransom',
            'cshields',
            'csorenson',
            'cturra',
            'deinspanjer',
            'dgherman',
            'dmaher',
            'dmitchell',
            'dmoore',
            'dparsons',
            'dthornton',
            'dwilson2',
            'elim',
            'eziegenhorn',
            'gcanavaggio',
            'gcox',
            'gdestuynder',
            'gene',
            'ghuerta',
            'heulalia',
            'hlangi',
            'hwine',
            'jarmstrong',
            'jbraddock',
            'jcook',
            'jcrowe',
            'jdow',
            'jford',
            'jhayashi',
            'jhopkins',
            'jlabian',
            'jlazaro',
            'jlin',
            'joduinn',
            'jstevensen',
            'jthomas',
            'juber',
            'justdave',
            'jvehent',
            'jwatkins',
            'jwood',
            "jyeo",
            'klibby',
            'kmoir',
            'lhirlimann',
            'lsblakk',
            'mcoates',
            'mcornmesser',
            'mgervasini',
            'mhenry',
            'mmayo',
            'mpressman',
            'mpurzynski',
            'mrz',
            'mshal',
            'nmaul',
            'nthomas',
            'oremj',
            'pchiasson',
            'pdang',
            'pmoore',
            'poneill',
            'pradcliffe',
            'qfortier',
            'raliiev',
            'rbryce',
            'rpina',
            'rsoderberg',
            'rtucker',
            'rwatson',
            'sbruno',
            'scabral',
            'sespinoza',
            'shnguyen',
            'shyam',
            'tfairfield',
            'tfranco',
            'tmary',
            'vdoan',
            'vhua',
            'wdawson',
            'xionox',
            'yshun',
        ]
    }
    $buildbot_mail_to = "release@mozilla.com"

    $vmwaretools_version = "9.0.5-1065307"
    $vmwaretools_md5 = "924b75b0b522eb462266cf3c24c98837"
    $collectd_graphite_cluster_fqdn = "graphite1.private.scl3.mozilla.com"
    $collectd_graphite_prefix = "hosts."
    $releaserunner_notify_from = "Release Eng <release@mozilla.com>"
    $releaserunner_notify_to = "Release Eng <release@mozilla.com>"
    $releaserunner_smtp_server = "localhost"
    $releaserunner_hg_username = "ffxbld"
    $releaserunner_hg_ssh_key = "/home/cltbld/.ssh/ffxbld_dsa"
    $releaserunner_production_masters = "http://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"
    $releaserunner_sendchange_master = "buildbot-master81.build.mozilla.org:9301"
    $releaserunner_ssh_username = "cltbld"
    $releaserunner_ssh_key = "/home/cltbld/.ssh/release-runner"
}

