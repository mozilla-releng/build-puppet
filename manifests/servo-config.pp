# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "servo"

    $puppet_notif_email = "releng-shared@mozilla.com"
    $puppet_server_reports = "tagmail,http"
    $puppet_server_reporturl = "http://foreman.pvt.build.mozilla.org:3001/"
    $puppet_server_facturl = "http://foreman.pvt.build.mozilla.org:3000/"

    $builder_username = "servobld"

    $puppet_servers = [
        "servo-puppet1.srv.servo.releng.use1.mozilla.com",
    ]
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server

    $distinguished_puppetmaster = $puppet_server
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet/"
    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'

    $nrpe_allowed_hosts = "127.0.0.1,10.26.75.30"
    $ntp_server = "time.mozilla.org"
    $admin_users = [
        # Servo users who should be kept when syncing from LDAP:
        'banderson',
        'jdm',
        'jmoffitt',
        'lbergstrom',
        # IT/RelEng:
        'achavez',
        'adam',
        'afernandez',
        'armenzg',
        'arr',
        'asasaki',
        'ashish',
        'bhearsum',
        'bhourigan',
        'bpannabecker',
        'catlee',
        'cknowles',
        'coop',
        'cshields',
        'dcurado',
        'dmitchell',
        'dmoore',
        'dparsons',
        'elim',
        'eziegenhorn',
        'gcox',
        'gdestuynder',
        'hwine',
        'jbryner',
        'jcrowe',
        'jdow',
        'jhopkins',
        'jlund',
        'jozeller',
        'jratford',
        'jstevensen',
        'justdave',
        'jvehent',
        'jwatkins',
        'jwood',
        'kmoir',
        'lhirlimann',
        'mcornmesser',
        'mgervasini',
        'mhenry',
        'mpurzynski',
        'mshal',
        'nthomas',
        'pmoore',
        'pradcliffe',
        'qfortier',
        'raliiev',
        'rbryce',
        'rsoderberg',
        'rtucker',
        'rwatson',
        'sbruno',
        'sespinoza',
        'shyam',
        'vhua',
        'vle',
        'xionox',
    ]
    $buildbot_mail_to = "release@mozilla.com"
    $bors_servo_repo_owner = "mozilla"
    $bors_servo_repo = "servo"
    $bors_servo_reviewers = [
        'aydinkim',
        'brson',
        'burg',
        'eric93',
        'glennw',
        'ILyoan',
        'jdm',
        'kmcallister',
        'larsbergstrom',
        'metajack',
        'mbrubeck',
        'Ms2ger',
        'pcwalton',
        'SimonSapin',
        'sfowler',
        'tkuehn',
        'yichoi',
        'zwarich',
    ]
    $bors_servo_builders = ["linux","mac"]
    $bors_servo_buildbot_url = "http://servo-buildbot.pub.build.mozilla.org"

    $xcode_version = $::macosx_productversion_major ? {
        10.7 => "4.6.2-cmdline",
        default => undef
    }
}

