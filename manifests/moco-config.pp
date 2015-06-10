# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = "moco"

    $puppet_notif_email = "releng-puppet-mail@mozilla.com"
    $puppet_server_reports = "tagmail,http"
    $puppet_server_reporturl = "http://foreman.pvt.build.mozilla.org:3001/"
    $puppet_server_facturl = "http://foreman.pvt.build.mozilla.org:3000/"

    $builder_username = "cltbld"
    $install_google_api_key = true
    $install_ceph_cfg = true
    $install_mozilla_geoloc_api_keys = true
    $install_google_oauth_api_key = true
    $install_crash_stats_api_token = true
    $install_adjust_sdk_token = true
    $install_relengapi_token = true

    # we use the sort_servers_by_group function to sort the list of servers, and then just use
    # the first as the primary server
    $grouped_puppet_servers = {
        '.*\.releng\.scl3\.mozilla\.com' => [
           "releng-puppet1.srv.releng.scl3.mozilla.com",
           "releng-puppet2.srv.releng.scl3.mozilla.com",
        ],
        '.*\.releng\.use1\.mozilla\.com' => [
           "releng-puppet1.srv.releng.use1.mozilla.com",
        ],
        '.*\.releng\.usw2\.mozilla\.com' => [
           "releng-puppet1.srv.releng.usw2.mozilla.com",
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
                'opsec' => ['team_opsec'],
            },
        }
    }

    # include this name in the master certs so that apt can validate the SSH
    # connection
    $puppetmaster_cert_extra_names = [$apt_repo_server]

    $user_python_repositories = [ "http://pypi.pvt.build.mozilla.org/pub", "http://pypi.pub.build.mozilla.org/pub" ]

    # Releng hosts are 'medium' by default.  Slaves are specifically overridden
    # with the 'low' level, and some others are flagged as 'high' or 'maximum'.
    $default_security_level = 'medium'

    $nrpe_allowed_hosts = "127.0.0.1,10.26.75.30"
    $ntp_servers = [ "ns1.private.releng.scl3.mozilla.com",
                     "ns2.private.releng.scl3.mozilla.com",
                     "ns1.private.phx1.mozilla.com",
                     "ns2.private.phx1.mozilla.com" ]
    $relayhost = "[smtp.mail.scl3.mozilla.com]"

    $enable_mig_agent = true

    $signer_username = 'cltsign'
    $signing_tools_repo = 'https://hg.mozilla.org/build/tools'
    $signing_mac_id = 'Mozilla'
    $signing_allowed_ips = [
        '10.26.36.0/22',
        '10.26.40.0/22',
        '10.134.68.32/32', # dev-master2
        '10.26.48.41/32',  # partner-repack1
        '10.26.44.0/22',
        '10.26.52.0/22',
        '10.26.64.0/22',
        '10.132.52.0/22',
        '10.132.64.0/22',
        '10.134.52.0/22',
        '10.134.64.0/22',
        # entire BB VLANs
        "10.26.68.0/24",
        "10.132.68.0/24",
        "10.134.68.0/24",
        "10.132.30.0/24",
        "10.134.30.0/24",
    ]
    $signing_new_token_allowed_ips = [
        '10.134.68.32/32', # dev-master2
        '10.26.48.41/32',  # partner-repack1
        # entire BB VLANs
        "10.26.68.0/24",
        "10.132.68.0/24",
        "10.134.68.0/24",
        "10.132.30.0/24",
        "10.134.30.0/24",
    ]

    $extra_user_ssh_keys = {
        # role accounts

        # used on buildbot masters
        'release-runner' => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDMCfdvoKtT4IU0cw6ckj748zxlr7wMxJfyRadUfpI+ZE6jOAjBrAxptVImaFYeVD9PFe5DXyAhRlhUPHSbtq+unMhkZrERYmUhxZ82TSqMSLDwMiacM0umXDnVqcs6cji5gjjE69TeLf9RywOzAmpU/JAasMDa7q4aNsccG7kj59vBl4yyZdx63yNNuxzBtvQd3LNjz2Ux3I60JZDM/xUu8eMBP9PDP5FIi4zILS8sKFzVD9l/7xsyLYv+IpFS1jLvX/eo0gKxM+27rlyyWET2mu/Vjw2J8gN6G9zh4nlMgEeeqFnR3ykFBgEl+LqM4PoH8xVzwZ1iZ8tDgP40nA3Z release-runner key'],
        'aws-ssh-key'  => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDVXLGITkkJL0lLIOqZh1hTZ59JoczFGQnaX6fHFxG0KdnD0qUQOXw5+gte+89vvvwdQybEBtH9+b+FeM4q1cOEfS+E5wJdzCqf3XRWrq9aNWMm3X4g+2aOlyc/O6+G6/WTXzUiBRKj9gDiodDYQFVEO01ytvIDKFuVZTLQTT/jveWArFFWsjvZZwj5RdAZQOoPylaNVzBnnoOxpn4iTowuXJ8QudzW47M9tLHHJWAGfGjejmS/rWKMnDmqHotQpLKUNItTogleFFdSDse2kkaABFYX65V1dbRQRh46hh+u0HDbFqdrTSEoHqRwmm6Varep7XjXi+Hdw3RiIs8LoNS1FKSEHfxDuc58kcPw/daq1n9a9nZK5g9V+4Oyn/ys9GcjZq44UCsjuJd0UI3Siz/I6vcBD9evzDjVHY4q3rdzv2Hdi0cDxBOgOBVWPUiwWsoHHXho2AFL/VyrEq525ib8cUT9jgod007JsgmlqVe/YyBeLSRHmSsAsKRE5tfnWlFJUygnPbkMugiWxxvFdEASKANvx+qxX96Uwr6a9Hi7OKVBKH886hLUP8+l5hVvOWLQW2uT7RRxIfRMg+fRIAROvydr9XiJiViFrSSR0dfeLghsHzzP6D5Voqad7scR9hMXuPMjx5PF9eX3D+XshAOSFzN2stWZFBRl4IxwSj3izQ== aws-ssh-key'],
    }

    # a few users from each team as the "short list" of people with access
    $shortlist = [
        # a few folks from relops..
        'arr',
        'dmitchell',
        'jwatkins',

        # ..and a few folks from releng
        'bhearsum',
        'catlee',
        'coop',
        'jwood',
        'nthomas',
        'raliiev',
    ]
    $admin_users = $fqdn ? {
        # signing machines have a very limited access list
        /^(mac-)?(v2-)?signing\d\..*/ => concat($shortlist, hiera('opsec')),
        default => hiera('ldap_admin_users',
                         # backup to ensure access in case the sync fails:
                         ['arr', 'dmitchell', 'jwatkins'])
    }
    $buildbot_mail_to = "release@mozilla.com"
    $master_json = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"

    $vmwaretools_version = "9.4.0-1280544"
    $vmwaretools_md5 = "4a2d230828919048c0c3ae8420f8edfe"
    # These need to be in "Foo <foo@bar.com>" style to work with release runner
    $releaserunner_notify_from = "Release Eng <release@mozilla.com>"
    $releaserunner_notify_to = "Release Notifications <release-automation-notifications@mozilla.com>"
    $releaserunner_smtp_server = "localhost"
    $releaserunner_hg_host = "hg.mozilla.org"
    $releaserunner_hg_username = "ffxbld"
    $releaserunner_hg_ssh_key = "/home/cltbld/.ssh/ffxbld_rsa"
    $releaserunner_production_masters = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"
    $releaserunner_sendchange_master = "buildbot-master81.build.mozilla.org:9301"
    $releaserunner_ssh_username = "cltbld"

    $shipit_notifier_api_root = "http://ship-it.mozilla.org"
    $shipit_notifier_verbose = true

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
    $selfserve_agent_clobberer_url = "https://api.pub.build.mozilla.org/clobberer/clobber/by-builder"
    $selfserve_agent_carrot_hostname = "releng-rabbitmq-zlb.webapp.scl3.mozilla.com"
    $selfserve_agent_carrot_vhost = "/buildapi"
    $selfserve_agent_carrot_userid = "buildapi"
    $selfserve_agent_carrot_exchange = "buildapi.control"
    $selfserve_agent_carrot_queue = "buildapi-agent-rabbit2"
    $selfserve_private_url = "http://buildapi.pvt.build.mozilla.org/buildapi/self-serve"

    $distinguished_aws_manager = "aws-manager2.srv.releng.scl3.mozilla.com"
    $aws_manager_mail_to = "release+aws-manager@mozilla.com"
    $cloudtrail_s3_bucket = "mozilla-releng-aws-logs"
    $cloudtrail_s3_base_prefix = "AWSLogs/314336048151/CloudTrail"
    # this is the dev instance at least until bug 929584 is fixed
    $slaverebooter_slaveapi = "http://slaveapi1.srv.releng.scl3.mozilla.com:8080"
    $slaverebooter_mail_to = "release@mozilla.com"

    $buildmaster_ssh_keys = [ 'b2gbld_dsa', 'b2gtry_dsa', 'ffxbld_rsa', 'tbirdbld_dsa', 'trybld_dsa', 'xrbld_dsa' ]

    $collectd_write = {
        graphite_nodes => {
            'graphite-relay.private.scl3.mozilla.com' => {
                'port' => '2003', 'prefix' => 'hosts.',
            },
        },
    }

    #### start configuration information for rsyslog logging

    # cef server for auditd output
    $cef_syslog_server = "syslog1.private.scl3.mozilla.com"

    # log aggregator settings per location/region
    #
    # note that the log aggregation file is overwritten via cloud-init in AWS
    # because the golden AMIs we generate are done in use1 and always specify
    # log-aggregator.srv.releng.use1.mozilla.com even for usw2 hosts
    # See https://github.com/mozilla/build-cloud-tools/pull/45

    $log_aggregator = $fqdn ? {
        /.*\.scl3\.mozilla\.com/ => 'log-aggregator.srv.releng.scl3.mozilla.com',
        /.*\.use1\.mozilla\.com/ => 'log-aggregator.srv.releng.use1.mozilla.com',
        /.*\.usw2\.mozilla\.com/ => 'log-aggregator.srv.releng.usw2.mozilla.com',
        default => '',
    }

    # we need to pick a logging port > 1024 for AWS to use the ELB
    $logging_port = $fqdn ? {
        /.*\.scl3\.mozilla\.com/ => '514',
        /.*\.(usw2|use1)\.mozilla\.com/ => '1514',
        default => '',
    }

    #### end configuration information for rsyslog logging

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
    $runner_clobberer_url = 'https://api.pub.build.mozilla.org/clobberer/lastclobber/all'

    # deploystudio
    $deploystudio_username = 'dsadmin'
    # deploystudio_uid must be an int greater than 500
    $deploystudio_uid = 543647
    # deploystudio root data directory
    $deploystudio_dir = "/Deploy"

    $xcode_version = $::macosx_productversion_major ? {
        10.6 => "4.2",
        10.7 => "4.1",
        10.8 => "5.1-cmdline",
        10.9 => "5.0-cmdline",
        10.10 => "6.1-cmdline",
        default => undef
    }

    # When specifying the Ununtu current kernel, you must use the fully qualified version of the package
    # The format is aa.bb.xx.yy.zz You can find this with 'dpkg -I linux-generic.deb'
    $current_kernel = $operatingsystem ? {
        'CentOS' => $operatingsystemrelease ? {
            '6.2'   => '2.6.32-504.3.3.el6',
            '6.5'   => '2.6.32-504.3.3.el6',
            default => undef,
        },
        'Ubuntu' => $operatingsystemrelease ? {
            '12.04' => '3.2.0.76.90',
            '14.04' => '3.13.0.45.52',
            default => undef,
        },
        default => undef,
    }

    # Specifying Ubuntu obsolete kernels is a different format than current kernel above
    # The format is aa.bb.xx-yy
    $obsolete_kernels = $operatingsystem ? {
        'CentOS' => $operatingsystemrelease ? {
            '6.2'   => [ '2.6.32-431.el6', '2.6.32-431.11.2.el6', '2.6.32-431.5.1.el6' ],
            '6.5'   => [ '2.6.32-431.el6', '2.6.32-431.11.2.el6', '2.6.32-431.5.1.el6' ],
            default => [],
        },
        'Ubuntu' => $operatingsystemrelease ? {
            '12.04' => [ '3.2.0-75', '3.2.0-38' ], 
            '14.04' => [ '3.13.0-27', '3.13.0-44' ],
            default => [],
        },
        default => [],
    }

    # bacula configuration

    $bacula_director = 'bacula1.private.scl3.mozilla.com'
    $bacula_fd_port = 9102
    # this isn't actually secret, but it's long, so we stick it in hiera.
    $bacula_cacert = secret('bacula_ca_cert')

    # Buildbot <-> Taskcluster bridge configuration
    $buildbot_bridge_root = "/builds/bbb"
    $buildbot_bridge_pulse_queue_basename = "queue/buildbot-bridge"
    $buildbot_bridge_tclistener_pulse_exchange_basename = "exchange/taskcluster-queue/v1"
    $buildbot_bridge_worker_type = "buildbot-bridge"
    $buildbot_bridge_provisioner_id = "buildbot-bridge"
    $buildbot_bridge_bblistener_pulse_exchange = "exchange/build"
    $buildbot_bridge_worker_group = "buildbot-bridge"
    $buildbot_bridge_worker_id = "buildbot-bridge"
    $buildbot_bridge_reflector_interval = 60

    # TC signing workers
    $signingworker_exchange = "exchange/taskcluster-queue/v1/task-pending"
    $signingworker_worker_type = "signing-worker-v1"

    # Funsize Scheduler configuration
    $funsize_scheduler_root = "/builds/funsize"
    $funsize_scheduler_balrog_username = "funsize"
    $funsize_scheduler_pulse_username = "funsize"
    $funsize_scheduler_pulse_queue = "scheduler"
    $funsize_scheduler_pulse_exchange = "exchange/build"
}
