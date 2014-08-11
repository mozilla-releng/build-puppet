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
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet/"
    $puppetmaster_extsyncs = {
        'fake_slavealloc' => {
            # No real slavealloc to use, so do this manually
        },
        'moco_ldap' => {
            'moco_ldap_uri' => 'ldap://ldap.mozilla.org/',
            'moco_ldap_root' => 'dc=mozilla',
            'moco_ldap_dn' => secret('moco_ldap_dn'),
            'moco_ldap_pass' => secret('moco_ldap_pass'),
            'users_in_groups' => {
                'ldap_admin_users' => [
                    'netops', 'team_dcops', 'team_opsec', 'team_moc', 'team_infra', 'team_storage'],
            },
        }
    }

    $admin_users = [
        # TODO: use unique(concat(..)) to concatenate the SM admins with a list of infra people
        "dmitchell",
        "ewong",
        "jwood",
        "kairo",
        "jdow",
    ]
    $master_json = "https://hg.mozilla.org/users/Callek_gmail.com/tools/raw-file/default/buildfarm/maintenance/sea-production-masters.json"
    $buildbot_tools_hg_repo = "https://hg.mozilla.org/users/Callek_gmail.com/tools/"
    $buildbot_configs_hg_repo = "https://hg.mozilla.org/build/buildbot-configs"
    $buildbot_configs_branch = "seamonkey-production"
    $buildbotcustom_branch = "seamonkey-production"
    $buildbot_mail_to = "seamonkey-release@mozilla.org"

    $buildmaster_ssh_keys = ['seabld_dsa', 'id_dsa']

    # runner task settings
    $runner_hg_tools_path = '/tools/checkouts/build-tools'
    $runner_hg_tools_repo = 'https://hg.mozilla.org/users/Callek_gmail.com/tools/'
    $runner_hg_tools_branch = 'default'
    $runner_hg_mozharness_path = '/tools/checkouts/mozharness'
    $runner_hg_mozharness_repo = 'https://hg.mozilla.org/build/mozharness'
    $runner_hg_mozharness_branch = 'production'
    $runner_env_hg_share_base_dir = '/builds/hg-shared'
    $runner_env_git_share_base_dir = '/builds/git-shared'
    $runner_buildbot_slave_dir = '/builds/slave'
}
