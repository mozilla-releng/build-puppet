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
           "releng-puppet1.srv.releng.scl3.mozilla.com",
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

    # this is a round-robin DNS containing all of the moco puppet masters.  This is the
    # only way to communicate to apt that the masters are all mirrors of one another.
    # See https://bugzilla.mozilla.org/show_bug.cgi?id=906785
    $apt_repo_server = "puppetagain-apt.pvt.build.mozilla.org"

    $distinguished_puppetmaster = "releng-puppet2.srv.releng.scl3.mozilla.com"
    $puppetmaster_public_mirror_hosts = [ "releng-puppet2.srv.releng.scl3.mozilla.com" ]
    $puppet_again_repo = "http://hg.mozilla.org/build/puppet/"

    $user_python_repositories = [ "http://pypi.pvt.build.mozilla.org/pub", "http://pypi.pub.build.mozilla.org/pub" ]

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
        '10.26.48.41',
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
        # NOTE: please copy this list to servo-config.pp as well
        default => [
            'achavez',
            'adam',
            'afernandez',
            'armenzg',
            'arr',
            'asasaki',
            'ashish',
            'bfenech',
            'bhearsum',
            'catlee',
            'coop',
            'dgherman',
            'dmitchell',
            'dmoore',
            'eramirez',
            'eziegenhorn',
            'gdestuynder',
            'hwine',
            'jarmstrong',
            'jbryner',
            'jford',
            'jhopkins',
            'jlund',
            'joduinn',
            'jpech',
            'jratford',
            'jstevensen',
            'jvehent',
            'jwatkins',
            'jwood',
            'kmoir',
            'lhirlimann',
            'lsblakk',
            'mcornmesser',
            'mgervasini',
            'mhenry',
            'mpurzynski',
            'mshal',
            'mtabara',
            'nthomas',
            'pmoore',
            'pradcliffe',
            'qfortier',
            'raliiev',
            'rbryce',
            'sbruno',
            'sespinoza',
            'shyam',
            'vhua',
            'vle',
            'xionox',
        ]
    }
    $buildbot_mail_to = "release@mozilla.com"

    $vmwaretools_version = "9.0.5-1065307"
    $vmwaretools_md5 = "924b75b0b522eb462266cf3c24c98837"
    $collectd_graphite_cluster_fqdn = "graphite-relay.private.scl3.mozilla.com"
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
    
    $install_avds = "yes"

    $slaveapi_slavealloc_url = "http://slavealloc.build.mozilla.org/api/"
    $slaveapi_inventory_url = "http://inventory.mozilla.org/en-US/tasty/v3/"
    $slaveapi_inventory_username = "releng-inventory-automation"
    $slaveapi_bugzilla_username = "slaveapi@mozilla.releng.tld"
    $slaveapi_default_domain = "build.mozilla.org"
    $slaveapi_ipmi_username = "releng"
    $slaveapi_bugzilla_dev_url = "https://bugzilla-dev.allizom.org/rest/"
    $slaveapi_bugzilla_prod_url = "https://bugzilla.mozilla.org/rest/"
}

