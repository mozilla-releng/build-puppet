# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "servo"

    $puppet_notif_email = "releng-shared@mozilla.com"
    $puppet_server_reports = "tagmail,http"
    $puppet_server_reporturl = "http://puppetdash.pvt.build.mozilla.org/reports/upload"
    $builder_username = "servobld"

    $puppet_servers = [
        "servo-puppet1.srv.servo.releng.use1.mozilla.com",
    ]
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server

    $distinguished_puppetmaster = $puppet_server
    $puppet_again_repo = "http://hg.mozilla.org/build/puppet/"
    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'

    $nrpe_allowed_hosts = "10.2.71.20,10.12.75.9,127.0.0.1,10.26.75.30"
    $ntp_server = "ntp.build.mozilla.org"
    $admin_users = [
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
        'banderson',
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
        'jlund',
        'jmoffitt',
        'joduinn',
        'jstevensen',
        'jthomas',
        'juber',
        'justdave',
        'jvehent',
        'jwatkins',
        'jwood',
        'jyeo',
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
    $buildbot_mail_to = "release@mozilla.com"
    $bors_servo_repo_owner = "mozilla"
    $bors_servo_repo = "servo"
    $bors_servo_reviewers = [
        'aydinkim',
        'brson',
        'burg',
        'ILyoan',
        'jdm',
        'kmcallister',
        'metajack',
        'pcwalton',
        'sfowler',
        'yichoi',
    ]
    $bors_servo_builders = ["linux", "mac"]
    $bors_servo_buildbot_url = "http://servo-buildbot.pub.build.mozilla.org"
}

