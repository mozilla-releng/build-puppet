# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# this class is temporary until bug 825056
class config inherits config::base {
    $org = "moco_aws_use1"

    # aws-specific stuff
    $crl_sync_url = "https://secure.pub.build.mozilla.org/aws-support/aws_ca_crl.pem"
    $puppet_server = "puppetmaster-02.srv.releng.aws-us-east-1.mozilla.com"
    $puppet_servers = [
        "puppetmaster-02.srv.releng.aws-us-east-1.mozilla.com"
    ]

    $puppet_notif_email = "releng-shared@mozilla.com"
    $builder_username = "cltbld"
    $use_random_order = false
    $data_servers = $puppet_servers
    $nrpe_allowed_hosts = "10.2.71.20,10.12.75.9,127.0.0.1,10.26.75.30"
    $ntp_server = "ntp.build.mozilla.org"
    $global_authorized_keys = [
        "armenzg",
        "arr",
        "asasaki",
        "bhearsum",
        "callek",
        "catlee",
        "cltbld",
        "coop",
        "dustin",
        "hwine",
        "jhopkins",
        "joduinn",
        "jwatkins",
        "jyeo",
        "kmoir",
        "mgervasini",
        "nthomas",
        "pmoore",
        "rail",
        "release-runner",
        "sbruno",
        "zandr",
    ]
    $buildbot_mail_to = "release@mozilla.com"
    $puppet_server_reports = "tagmail,http"
    $puppet_server_reporturl = "http://puppetdash.pvt.build.mozilla.org/reports/upload"
}
