# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Config
# if you add a new key here, add it to the wiki as well!

# the keys in this file are documented in
#   https://wiki.mozilla.org/ReleaseEngineering/PuppetAgain#Config
# if you add a new key here, add it to the wiki as well!

# This class is overridden by the org-specific config symlinked from manifests/config.pp

class config::base {
    $org = undef

    $manage_ifcfg = true
    $puppet_notif_email = "nobody@mozilla.com"
    $data_server = "repos"
    $data_servers = [$data_server]
    $apt_repo_server = $data_server
    $puppet_servers = "puppet"
    $puppet_server = [$puppet_servers]
    $distinguished_puppetmaster = ''
    $puppetmaster_upstream_rsync_source = ''
    $puppetmaster_upstream_rsync_args = ''
    $puppetmaster_public_mirror_hosts = []
    $builder_username = 'cltbld'
    $signer_username = 'cltsign'
    $nrpe_allowed_hosts = '127.0.0.1'
    $ntp_server = "pool.ntp.org"
    $relay_domains = "smtp.mozilla.org"
    $puppet_again_repo = "http://hg.mozilla.org/build/puppet"
    $puppet_server_reports = "tagmail"
    $puppet_server_reporturl = "http://localhost:3000/reports/upload"
    $master_json = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"
    $buildbot_tools_hg_repo = "https://hg.mozilla.org/build/tools"
    $buildbot_configs_hg_repo = "https://hg.mozilla.org/build/buildbot-configs"
    $buildbot_configs_branch = "production"
    $buildbotcustom_branch = "production-0.8"
    $buildbot_mail_to = "nobody@mozilla.com"
    $collectd_graphite_cluster_fqdn = ""
    $collectd_graphite_prefix = ""
    $signing_tools_repo = 'http://hg.mozilla.org/build/tools'
    $signing_redis_host = ''
    $signing_mac_id = ''
    $signing_allowed_ips = []
    $signing_new_token_allowed_ips = []
    $vmwaretools_version = ""
    $vmwaretools_md5 = ""
    $admin_users = []
    $users = []
    $release_runner_root = "/builds/releaserunner"
    $releaserunner_buildbot_configs = "http://hg.mozilla.org/build/buildbot-configs"
    $releaserunner_buildbot_configs_branch = "production"
    $releaserunner_buildbotcustom = "http://hg.mozilla.org/build/buildbotcustom"
    $releaserunner_buildbotcustom_branch = "production-0.8"
    $releaserunner_tools = "http://hg.mozilla.org/build/tools"
    $releaserunner_tools_branch = "default"
    $releaserunner_notify_from = ""
    $releaserunner_notify_to = ""
    $releaserunner_smtp_server = ""
    $releaserunner_hg_username = ""
    $releaserunner_hg_ssh_key = ""
    $releaserunner_production_masters = ""
    $releaserunner_sendchange_master = ""
    $releaserunner_ssh_username = ""
    $releaserunner_ssh_key = ""
    $install_avds = "no"
}
