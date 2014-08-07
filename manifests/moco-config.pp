# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "moco"

    $puppet_notif_email = "releng-shared@mozilla.com"
    $puppet_server_reports = "tagmail,http"
    $puppet_server_reporturl = "http://foreman.pvt.build.mozilla.org:3001/"
    $puppet_server_facturl = "http://foreman.pvt.build.mozilla.org:3000/"

    $builder_username = "cltbld"
    $install_google_api_key = true
    $install_ceph_cfg = true
    $install_mozilla_api_key = true

    # we use the sort_servers_by_group function to sort the list of servers, and then just use
    # the first as the primary server
    $grouped_puppet_servers = {
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

    $node_location = $fqdn? {
        /.*\.scl3\.mozilla\.com/ => 'in-house',
        /.*\.use1\.mozilla\.com/ => 'aws',
        /.*\.usw2\.mozilla\.com/ => 'aws',
        default => 'unknown',
    }

    # this is a round-robin DNS containing all of the moco puppet masters.  This is the
    # only way to communicate to apt that the masters are all mirrors of one another.
    # See https://bugzilla.mozilla.org/show_bug.cgi?id=906785
    $apt_repo_server = "puppetagain-apt.pvt.build.mozilla.org"

    $distinguished_puppetmaster = "releng-puppet2.srv.releng.scl3.mozilla.com"
    $puppetmaster_public_mirror_hosts = [ "releng-puppet2.srv.releng.scl3.mozilla.com" ]
    $puppet_again_repo = "https://hg.mozilla.org/build/puppet/"
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
    $puppetmaster_syslog_server = "syslog1.private.scl3.mozilla.com"

    $user_python_repositories = [ "http://pypi.pvt.build.mozilla.org/pub", "http://pypi.pub.build.mozilla.org/pub" ]

    $nrpe_allowed_hosts = "127.0.0.1,10.26.75.30"
    $ntp_server = "time.mozilla.org"
    $relayhost = "[smtp.mozilla.org]"

    $signer_username = 'cltsign'
    $signing_tools_repo = 'https://hg.mozilla.org/build/tools'
    $signing_mac_id = 'Mozilla'
    $signing_allowed_ips = [
        '10.26.36.0/22',
        '10.26.40.0/22',
        '10.26.48.0/24',
        '10.26.44.0/22',
        '10.26.52.0/22',
        '10.26.64.0/22',
        '10.132.48.0/22',
        '10.132.52.0/22',
        '10.132.64.0/22',
        '10.134.48.0/22',
        '10.134.52.0/22',
        '10.134.64.0/22',
        '10.250.48.0/22',
    ]
    $signing_new_token_allowed_ips = [
        '10.26.48.41',
        '10.26.48.52',
        '10.26.48.53',
        '10.26.48.54',
        '10.26.48.55',
        '10.26.48.56',
        '10.26.48.57',
        '10.132.48.136',
        '10.132.49.94',
        '10.132.49.117',
        '10.132.49.158',
        '10.132.49.181',
        '10.132.50.54',
        '10.134.48.7',
        '10.134.48.40',
        '10.134.48.86',
        '10.134.49.77',
        '10.134.49.94',
        '10.134.49.111',
        '10.26.48.25',
    ]

    $extra_user_ssh_keys = {
        # role accounts

        # used on buildbot masters
        'release-runner' => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMCfdvoKtT4IU0cw6ckj748zxlr7wMxJfyRadUfpI+ZE6jOAjBrAxptVImaFYeVD9PFe5DXyAhRlhUPHSbtq+unMhkZrERYmUhxZ82TSqMSLDwMiacM0umXDnVqcs6cji5gjjE69TeLf9RywOzAmpU/JAasMDa7q4aNsccG7kj59vBl4yyZdx63yNNuxzBtvQd3LNjz2Ux3I60JZDM/xUu8eMBP9PDP5FIi4zILS8sKFzVD9l/7xsyLYv+IpFS1jLvX/eo0gKxM+27rlyyWET2mu/Vjw2J8gN6G9zh4nlMgEeeqFnR3ykFBgEl+LqM4PoH8xVzwZ1iZ8tDgP40nA3Z release-runner key'],
    }

    $admin_users = $fqdn ? {
        # signing machines have a very limited access list
        /^(mac-(v2-|))?signing\d\..*/ => [
            # a few folks from relops..
            'arr',
            'dmitchell',
            'jwatkins',

            # ..and a few folks from releng
            'bhearsum',
            'catlee',
            'coop',
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
            'iconnolly',
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
            'mhommey',
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
            'tglek',
            'vhua',
            'vle',
            'xionox',
        ]
    }
    $buildbot_mail_to = "release@mozilla.com"
    $master_json = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"

    $vmwaretools_version = "9.4.0-1280544"
    $vmwaretools_md5 = "4a2d230828919048c0c3ae8420f8edfe"
    $releaserunner_notify_from = "Release Eng <release@mozilla.com>"
    $releaserunner_notify_to = "Release Drivers <release-drivers@mozilla.org>"
    $releaserunner_smtp_server = "localhost"
    $releaserunner_hg_host = "hg.mozilla.org"
    $releaserunner_hg_username = "ffxbld"
    $releaserunner_hg_ssh_key = "/home/cltbld/.ssh/ffxbld_dsa"
    $releaserunner_production_masters = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"
    $releaserunner_sendchange_master = "buildbot-master81.build.mozilla.org:9301"
    $releaserunner_ssh_username = "cltbld"

    $slaveapi_slavealloc_url = "http://slavealloc.build.mozilla.org/api/"
    $slaveapi_inventory_url = "https://inventory.mozilla.org/en-US/tasty/v3/"
    $slaveapi_inventory_username = "releng-inventory-automation"
    $slaveapi_buildapi_url = "http://buildapi.pvt.build.mozilla.org/buildapi/"
    $slaveapi_bugzilla_username = "slaveapi@mozilla.releng.tld"
    $slaveapi_default_domain = "build.mozilla.org"
    $slaveapi_ipmi_username = "releng"
    $slaveapi_bugzilla_dev_url = "https://bugzilla-dev.allizom.org/rest/"
    $slaveapi_bugzilla_prod_url = "https://bugzilla.mozilla.org/rest/"

    $selfserve_agent_sendchange_master = "bm81-build_scheduler"
    $selfserve_agent_branches_json = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-branches.json"
    $selfserve_agent_masters_json = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"
    $selfserve_agent_clobberer_url = "http://clobberer.pvt.build.mozilla.org/index.php"
    $selfserve_agent_carrot_hostname = "releng-rabbitmq-zlb.webapp.scl3.mozilla.com"
    $selfserve_agent_carrot_vhost = "/buildapi"
    $selfserve_agent_carrot_userid = "buildapi"
    $selfserve_agent_carrot_exchange = "buildapi.control"
    $selfserve_agent_carrot_queue = "buildapi-agent-rabbit2"

    $aws_manager_mail_to = "release+aws-manager@mozilla.com"
    $cloudtrail_s3_bucket = "mozilla-releng-aws-logs"
    $cloudtrail_s3_base_prefix = "AWSLogs/314336048151/CloudTrail"
    # this is the dev instance at least until bug 929584 is fixed
    $slaverebooter_slaveapi = "http://slaveapi1.srv.releng.scl3.mozilla.com:8080"
    $slaverebooter_mail_to = "release@mozilla.com"

    $buildmaster_ssh_keys = [ 'b2gbld_dsa', 'b2gtry_dsa', 'ffxbld_dsa', 'tbirdbld_dsa', 'trybld_dsa', 'xrbld_dsa' ]

    $collectd_write = {
        graphite_nodes => {
            'graphite-relay.private.scl3.mozilla.com' => {
                'port' => '2003', 'prefix' => 'hosts.',
            },
        },
    }

    # hosted graphite settings
    $diamond_graphite_host = "mozilla.carbon.hostedgraphite.com"
    $diamond_graphite_port = "2003"
    $diamond_graphite_path_prefix = secret('diamond_api_key')
    $diamond_batch_size = 1
    $diamond_poll_interval = 30


    # runner task settings
    $runner_hg_tools_path = '/tools/checkouts/build-tools'
    $runner_hg_tools_repo = 'https://hg.mozilla.org/build/tools'
    $runner_hg_tools_branch = 'default'
    $runner_hg_mozharness_path = '/tools/checkouts/mozharness'
    $runner_hg_mozharness_repo = 'https://hg.mozilla.org/build/mozharness'
    $runner_hg_mozharness_branch = 'production'

    $runner_env_hg_share_base_dir = '/builds/hg-shared'
    $runner_env_git_share_base_dir = '/builds/git-shared'

    $runner_buildbot_slave_dir = '/builds/slave'



    $xcode_version = $::macosx_productversion_major ? {
        10.6 => "4.2",
        10.7 => "4.1",
        10.8 => "4.5-cmdline",
        10.9 => "5.0-cmdline",
        default => undef
    }
}
