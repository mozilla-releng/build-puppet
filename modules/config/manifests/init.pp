# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Config
# if you add a new key here, add it to the wiki as well!

# We use config rather than settings because "settings" is a magic class
class config {
    include config::secrets

    $puppet_notif_email = extlookup("puppet_notif_email")
    $data_server = extlookup("data_server")
    $data_servers = extlookup("data_servers")
    $puppet_servers = extlookup("puppet_servers")
    # use a random puppet master if pupper_server is not defined
    $random_puppet_server = template("config/calculate-random-puppet-server.erb")
    # Use randmom puppet server from puppet_servers if it's set to <<RANDOM>>
    if extlookup("puppet_server") == "<<RANDOM>>" {
        $use_random_order = true
        $puppet_server = $random_puppet_server
    } else {
        $use_random_order = false
        $puppet_server = extlookup("puppet_server")
    }
    $builder_username = extlookup("builder_username")
    $nrpe_allowed_hosts = extlookup("nrpe_allowed_hosts")
    $ntp_server = extlookup("ntp_server")
    $relay_domains = extlookup("relay_domains")
    $ganglia_config_class = extlookup("ganglia_config_class", "")
    $crl_sync_url= extlookup("crl_sync_url", "")
    $puppet_again_repo = extlookup("puppet_again_repo")
    $global_authorized_keys = extlookup("global_authorized_keys", "")
    $puppet_server_reports = extlookup("puppet_server_reports")
    $puppet_server_reporturl = extlookup("puppet_server_reporturl")
    $master_json = extlookup("master_json")
    $buildbot_tools_hg_repo = extlookup("buildbot_tools_hg_repo")
    $buildbot_configs_hg_repo = extlookup("buildbot_configs_hg_repo")
    $buildbot_configs_branch = extlookup("buildbot_configs_branch")
    $buildbot_mail_to = extlookup("buildbot_mail_to")
}
