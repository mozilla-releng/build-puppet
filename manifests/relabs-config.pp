# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "relabs"

    $puppet_notif_email = "dustin@mozilla.com"
    $builder_username = "relabsbld"
    $grouped_puppet_servers = {
        ".*" => [
            "relabs-puppet2.relabs.releng.scl3.mozilla.com",
        ],
    }
    $puppet_servers = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server = $puppet_servers[0]
    $data_servers = $puppet_servers
    $data_server = $puppet_server
    $apt_repo_server = $data_server

    $distinguished_puppetmaster = "relabs-puppet2.relabs.releng.scl3.mozilla.com"
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet/"

    $puppet_server_reports = "http"
    $puppet_server_reporturl = "http://foreman.pvt.build.mozilla.org:3001/"
    $puppet_server_facturl = "http://foreman.pvt.build.mozilla.org:3000/"
    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppetmaster_public_mirror_hosts = [ ]
    $puppetmaster_extsyncs = {
        'slavealloc' => {
            'slavealloc_api_url' => 'http://slavealloc.pvt.build.mozilla.org/api/',
        },
        'moco_ldap' => {
            'moco_ldap_uri' => 'ldap://ldap.db.scl3.mozilla.com/',
            'moco_ldap_root' => 'dc=mozilla',
            'moco_ldap_dn' => secret('moco_ldap_dn'),
            'moco_ldap_pass' => secret('moco_ldap_pass'),
            'users_in_groups' => {
                'ldap_admin_users' => ['releng', 'relops',
                'netops', 'team_dcops', 'team_opsec', 'team_moc', 'team_infra', 'team_storage'],
            },
        }
    }

    $signer_username = 'relabssign'
    $signing_tools_repo = 'https://hg.mozilla.org/build/tools'
    $signing_redis_host = 'localhost'
    $signing_mac_id = 'Relabs'
    $signing_allowed_ips = [
        '10.250.48.0/22',
        '10.26.78.0/24',
    ]
    $signing_new_token_allowed_ips = [
        '10.250.48.1', # fake
    ]

    $vmwaretools_version = "9.4.0-1280544"
    $vmwaretools_md5 = "4a2d230828919048c0c3ae8420f8edfe"

    $ntp_server = "time.mozilla.org"
    $enable_mig_agent = true

    $extra_user_ssh_keys = {
        # role accounts  (just here to test $extra_user_ssh_keys)
        'release-runner' => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMCfdvoKtT4IU0cw6ckj748zxlr7wMxJfyRadUfpI+ZE6jOAjBrAxptVImaFYeVD9PFe5DXyAhRlhUPHSbtq+unMhkZrERYmUhxZ82TSqMSLDwMiacM0umXDnVqcs6cji5gjjE69TeLf9RywOzAmpU/JAasMDa7q4aNsccG7kj59vBl4yyZdx63yNNuxzBtvQd3LNjz2Ux3I60JZDM/xUu8eMBP9PDP5FIi4zILS8sKFzVD9l/7xsyLYv+IpFS1jLvX/eo0gKxM+27rlyyWET2mu/Vjw2J8gN6G9zh4nlMgEeeqFnR3ykFBgEl+LqM4PoH8xVzwZ1iZ8tDgP40nA3Z release-runner key'],
    }
    $admin_users = [
        "arr",
        "bhearsum",
        "catlee",
        "dmitchell",
        "jwatkins",
        "jwood",
        "raliiev",
        "cknowles",
        "dmaher",
        "hskupin",
        "pchiasson",
        "jvehent",
    ]
}

