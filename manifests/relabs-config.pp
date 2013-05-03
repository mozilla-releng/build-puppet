# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "relabs"

    $puppet_notif_email = "dustin@mozilla.com"
    $puppet_server_reports = ""
    $builder_username = "relabsbld"
    $use_random_order = false
    $puppet_server = "relabs03.build.mtv1.mozilla.com"
    $puppet_servers = [ "relabs03.build.mtv1.mozilla.com" ]
    $data_servers = $puppet_servers

    $distinguished_puppetmaster = "relabs03.build.mtv1.mozilla.com"
    $puppet_again_repo = "http://hg.mozilla.org/users/dmitchell_mozilla.com/puppet320/"

    $ntp_server = "ntp.build.mozilla.org"
    $global_authorized_keys = [
        "arr",
        "bhearsum",
        "callek",
        "catlee",
        "dustin",
        "rail",
    ]
}

