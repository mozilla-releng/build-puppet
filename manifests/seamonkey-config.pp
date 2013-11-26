# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# We use config rather than settings because "settings" is a magic class
class config inherits config::base {
    $org = "seamonkey"

    $manage_ifcfg = false # SeaMonkey expects to set IP/gateway manually

    $puppet_notif_email = "seamonkey-release@mozilla.org"
    $builder_username = "seabld"

    $puppet_servers = [
        "sea-puppet.community.scl3.mozilla.com"
    ]
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server

    $distinguished_puppetmaster = "sea-puppet.community.scl3.mozilla.com"
    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppet_again_repo = "http://hg.mozilla.org/build/puppet/"

    $admin_users = [
        "dmitchell",
        "ewong",
        "jwood",
        "kairo",
    ]
    $master_json = "https://hg.mozilla.org/users/Callek_gmail.com/tools/raw-file/default/buildfarm/maintenance/sea-production-masters.json"
    $buildbot_tools_hg_repo = "https://hg.mozilla.org/users/Callek_gmail.com/tools/"
    $buildbot_configs_hg_repo = "https://hg.mozilla.org/build/buildbot-configs"
    $buildbot_configs_branch = "seamonkey-production"
    $buildbotcustom_branch = "seamonkey-production"
    $buildbot_mail_to = "seamonkey-release@mozilla.org"

    $buildmaster_ssh_keys = ['seabld_dsa', 'id_dsa']
}
