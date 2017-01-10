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
    $install_release_s3_credentials = true

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
                'ldap_admin_users' => ['releng', 'relops'],
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
                     "ns1.private.scl3.mozilla.com",
                     "ns2.private.scl3.mozilla.com" ]
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
        'release-runner' => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC/hnLTj8YKCoVTnLkTE3LjFgXJI2snN3fvCbuUzB/B9cxrdL1FjCMIeUPeM6u2z1f7F2/h7zAA+9WM5Gb5in6gepJ2gu6lVc8ny6PehkDbhtD2fvclpbG91Eoxa9AkNGlxJ+8zMG2guXR1klXHAGiIdeXnAK2+iCrErJfcjKCopxsPP3DmhwvHwHDNSNuRRKQ1zZaLbsaCkjDvxLzobb6lWSg3gEZoKPXXg6+tVwy565SAq2IsuaiOyvjrdiELlaFPnupkeCl5WCBkFxBx3upWQdUzCZypiwW9wU0P97wvhzW12UqU3XYqnn6zqsMIDUOJ+UWSbQ1s1jcbLDKrCCyhYZt/1Q9AUdnjzY7L9vfPJvPGpu7EoQ8DPXGzQhsIpNcoyc5xeLxgr9tAnhkyW7E36oOtvEh3G8v/Cz8mWqtQ+zcKFqFz0wzM4BHnc5I/S7GtEncgLeS+bXy5ye9FIjjsNHM5FcMRXVj2nBJDLe9nt0kRZXnOieV9Je0a8O7kwXkkD1f2+axjBB9EoB8q5IDhNfKE1AEBHNZ3sVNxgRYLJrgFPpnlABshp1kJk1eF1l+d+Moe/9cmHLb4zgDDBLXjNHt9qz30/jazgzI8/V+nkIsbCiglnF4GlboK3w14DaxIPX+k0oepJA/TpFsF8v+JN/NAF2ZGJ24Rm1Yjh/lEYQ== Releng RSA key release-runner on 2016-04-27'],
        'aws-ssh-key'  => ['ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDo5tcTXknyfEUUXVKd8wWGeA+z1UYHvVbONIcpwE+74GqiTTr4BpXtD7J9i0a+B/ogQieUwKevGIFPCekyM2c0Fp8bdkuhaRRaibPNipvaD5s+rWiGyB9zbUnlq6GkCTbZdbuZNjK/wMrBAB7+uMIHuSrmUWDQXrU4zqmk/gUT6Xpf3JyyiVtyoZvoPZWTRPvFGbo8A4n/jSXCBjzH/tYj2swwThz0EOxZFazlKT5uYiIyuWMKSMl5tY9P8Us6AOYXyeV69SNl9wzAD9lKOT+Cv3xiCkp3HSxPrh6tpMuzvjlYF+iJewGizoDRDv1QAzCxpNU4sbgu8c94Y2ubBeBd+w2DW81Lo8t9YSDocz4iXlXmOoPJXfBlIR9aT+lOZS84i0liFl4pu5WV/oNszGsM1Hv8y6F90jntHbkZtnvbfyx4BBkzwl1TsMHSbtCsYQTn9xUQNL9cDh6rTE87PgeIdoSlZHsStY891LDOmQQOFefamcyMMheVy9Mi1nbJ4LN/IOxklGapnrrspFHUwpISjF8Z7UB8Z/rCb1EjpDIOIWzR0Vxbhej8JKu2OU9Pe2/tLbJPcAnyOGoVS/bHLKX8uN0Q7bRaaHQ2kP7n5HoAMOap1JjqZ830knfscmWyo1rMAfCzYVUBj/LHTuo2sa33srdCK3wzfMpuGWrNPqS/vQ== Releng RSA key aws-releng on 2016-04-27'],
    }
    $signing_server_ssl_private_keys = hiera_hash('signing_server_ssl_private_keys')
    $signing_server_ssl_certs = hiera_hash("signing_server_ssl_certs")


    # a few users from each team as the "short list" of people with access
    $shortlist = [
        # a few folks from relops..
        'arr',
        'klibby',
        'jwatkins',

        # ..and a few folks from releng
        'asasaki',
        'bhearsum',
        'catlee',
        'coop',
        'jwood',
        'nthomas',
        'raliiev',
        'kmoir',
    ]
    $admin_users = $fqdn ? {
        # signing machines have a very limited access list
        /^(mac-)?(v2-)?signing\d\..*/ => $shortlist,
        /^signing-linux-\d\..*/ => $shortlist,
        /signingworker-.*\.srv\.releng\..*\.mozilla\.com/ => $shortlist,
        default => hiera('ldap_admin_users',
                         # backup to ensure access in case the sync fails:
                         ['arr', 'klibby', 'jwatkins'])
    }
    $only_user_ssh = $fqdn ? {
        # signing machines disallow root and password-based ssh
        /^(mac-)?(v2-)?signing\d\..*/ => true,
        /^signing-linux-\d\..*/ => true,
        /signingworker-.*\.srv\.releng\..*\.mozilla\.com/ => true,
        default => false
    }
    $buildbot_mail_to = "release@mozilla.com"
    $master_json = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"

    $vmwaretools_version = "10.0.9-3917699"
    $vmwaretools_md5 = "160979c6d9f5b0979d81b3b6c15d0b1a"
    # These need to be in "Foo <foo@bar.com>" style to work with release runner
    $releaserunner_notify_from = "Release Eng <release@mozilla.com>"
    $releaserunner_smtp_server = "localhost"
    $releaserunner_hg_host = "hg.mozilla.org"
    $releaserunner_hg_username = "ffxbld"
    $releaserunner_hg_ssh_key = "/home/cltbld/.ssh/ffxbld_rsa"
    $releaserunner_production_masters = "https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json"
    $releaserunner_sendchange_master = "buildbot-master81.build.mozilla.org:9301"
    $releaserunner_ssh_username = "cltbld"

    $releaserunner_env_config = {
        "dev" => {
            ship_it_root => "https://ship-it-dev.allizom.org",
            ship_it_username => secret("releaserunner_dev_ship_it_username"),
            ship_it_password => secret("releaserunner_dev_ship_it_password"),
            notify_to => "Release Notifications Dev <release-automation-notifications-dev@mozilla.com>",
            notify_to_announce => "Release Notifications Dev <release-automation-notifications-dev@mozilla.com>",
            allowed_branches => "date",
            taskcluster_client_id => secret("releaserunner_dev_taskcluster_client_id"),
            taskcluster_access_token => secret("releaserunner_dev_taskcluster_access_token"),
            balrog_username => "stage-ffxbld",
            balrog_password => secret("stage-ffxbld_ldap_password"),
            beetmover_aws_access_key_id => secret("stage-beetmover-aws_access_key_id"),
            beetmover_aws_secret_access_key => secret("stage-beetmover-aws_secret_access_key"),
            releaserunner_buildbot_configs_branch => "default",
            releaserunner_buildbot_configs => "https://hg.mozilla.org/build/buildbot-configs",
            releaserunner_gpg_key_path => "scripts/release/KEY",
        },
        "prod" => {
            ship_it_root => "https://ship-it.mozilla.org",
            ship_it_username => secret("releaserunner_prod_ship_it_username"),
            ship_it_password => secret("releaserunner_prod_ship_it_password"),
            notify_to => "Release Notifications <release-automation-notifications@mozilla.com>",
            notify_to_announce => "Release Co-ordination <release-drivers@mozilla.org>",
            allowed_branches => "mozilla-beta,mozilla-release,mozilla-esr,comm-beta,comm-esr",
            taskcluster_client_id => secret("releaserunner_prod_taskcluster_client_id"),
            taskcluster_access_token => secret("releaserunner_prod_taskcluster_access_token"),
            balrog_username => "ffxbld",
            balrog_password => secret("ffxbld_ldap_password"),
            beetmover_aws_access_key_id => secret("beetmover-aws_access_key_id"),
            beetmover_aws_secret_access_key => secret("beetmover-aws_secret_access_key"),
            releaserunner_buildbot_configs_branch => "production",
            releaserunner_buildbot_configs => "https://hg.mozilla.org/build/buildbot-configs",
            releaserunner_gpg_key_path => "scripts/release/KEY",
        }
    }

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
    $selfserve_agent_allthethings_json = "https://secure.pub.build.mozilla.org/builddata/reports/allthethings.json"
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

    $buildmaster_ssh_keys = [ 'ffxbld_rsa', 'tbirdbld_dsa', 'trybld_dsa' ]

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
            '12.04' => [ '3.2.0-75', '3.2.0-38', '3.5.0-18'],
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
    $buildbot_bridge_tclistener_pulse_exchange_basename = "exchange/taskcluster-queue/v1"
    $buildbot_bridge_worker_type = "buildbot-bridge"
    $buildbot_bridge_provisioner_id = "buildbot-bridge"
    $buildbot_bridge_bblistener_pulse_exchange = "exchange/build"
    $buildbot_bridge_worker_group = "buildbot-bridge"
    $buildbot_bridge_worker_id = "buildbot-bridge"
    $buildbot_bridge_reflector_interval = 60

    $buildbot_bridge_env_config = {
        "dev" => {
            version => "1.5.24",
            client_id => secret("buildbot_bridge_dev_taskcluster_client_id"),
            access_token => secret("buildbot_bridge_dev_taskcluster_access_token"),
            dburi => secret("buildbot_bridge_dev_dburi"),
            pulse_username => secret("buildbot_bridge_dev_pulse_username"),
            pulse_password => secret("buildbot_bridge_dev_pulse_password"),
            pulse_queue_basename => "queue/buildbot-bridge-dev",
            restricted_builders => [
                "^release-.*$",
            ],
            ignored_builders => [
                "^((?!(alder|-date|jamun)).)*$",
            ],
        },
        "prod" => {
            version => "1.5.24",
            client_id => secret("buildbot_bridge_prod_taskcluster_client_id"),
            access_token => secret("buildbot_bridge_prod_taskcluster_access_token"),
            dburi => secret("buildbot_bridge_prod_dburi"),
            pulse_username => secret("buildbot_bridge_prod_pulse_username"),
            pulse_password => secret("buildbot_bridge_prod_pulse_password"),
            pulse_queue_basename => "queue/buildbot-bridge",
            restricted_builders => [
                "^release-.*$",
            ],
            ignored_builders => [
                "^.*alder.*$",
                "^.*jamun.*$",
                "^.*-date.*$",
            ],
        }
    }

    # TC signing workers
    $signingworker_exchange = "exchange/taskcluster-queue/v1/task-pending"
    $signingworker_worker_type = "signing-worker-v1"

    # scriptworker
    $scriptworker_root = "/builds/scriptworker"
    $scriptworker_gpg_private_keys = hiera_hash('scriptworker_gpg_private_keys')
    $scriptworker_gpg_public_keys = hiera_hash('scriptworker_gpg_public_keys')

    # TC balrog scriptworkers

    # TC beetmover scriptworkers
    $beetmover_scriptworker_task_max_timeout = 2400
    $beetmover_scriptworker_artifact_expiration_hours = 336
    $beetmover_scriptworker_artifact_upload_timeout = 600
    $beetmover_scriptworker_verbose_logging = false
    $beetmover_scriptworker_root = "/builds/beetmoverworker"
    $beetmover_scriptworker_env_config = {
        "dev" => {
            provisioner_id => "scriptworker-prov-v1",
            worker_group => "beetmoverworker-v1",
            worker_type => "beetmoverworker-v1",
            taskcluster_client_id => secret("beetmoverworker_dev_taskcluster_client_id"),
            taskcluster_access_token => secret("beetmoverworker_dev_taskcluster_access_token"),
            beetmover_aws_access_key_id => secret("nightly-beetmover-aws_access_key_id"),
            beetmover_aws_secret_access_key => secret("nightly-beetmover-aws_secret_access_key"),
            beetmover_aws_s3_firefox_bucket => "net-mozaws-prod-delivery-firefox",
            beetmover_aws_s3_fennec_bucket => "net-mozaws-prod-delivery-archive",
        }
    }

    ## TC pushapk scriptworkers
    $pushapk_scriptworker_old_root = '/builds/pushapkworker' # TODO Remove this line once bug 1321513 reaches production
    $pushapk_scriptworker_root = $scriptworker_root
    $pushapk_scriptworker_worker_config = "${pushapk_scriptworker_root}/config.json"
    $pushapk_scriptworker_script_config = "${pushapk_scriptworker_root}/script_config.json"

    $pushapk_scriptworker_jarsigner_keystore = "${pushapk_scriptworker_root}/mozilla-android-keystore"
    $pushapk_scriptworker_jarsigner_nightly_certificate_alias = 'nightly'
    $pushapk_scriptworker_jarsigner_release_certificate_alias = 'release'
    $pushapk_scriptworker_taskcluster_artifact_expiration_hours = 336
    $pushapk_scriptworker_taskcluster_artifact_upload_timeout = 1200
    $pushapk_scriptworker_task_max_timeout = 1200
    $pushapk_scriptworker_artifact_expiration_hours = 336
    $pushapk_scriptworker_artifact_upload_timeout = 600
    $pushapk_scriptworker_env_config = {
      'dev' => {
        provisioner_id => 'scriptworker-prov-v1',
        worker_group => 'pushapk-v1-dev',
        worker_type => 'pushapk-v1-dev',
        worker_id => 'jlorenzo-dev',
        verbose_logging => true,
        taskcluster_client_id => secret('pushapk_scriptworker_taskcluster_client_id_dev'),
        taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_dev'),
        google_play_config => {
          'aurora' => {
            service_account => secret('pushapk_scriptworker_aurora_google_play_service_account_dev'),
            certificate => secret('pushapk_scriptworker_aurora_google_play_certificate_dev'),
            certificate_target_location => "${pushapk_scriptworker_root}/aurora.p12",
          },
          'beta' => {
            service_account => secret('pushapk_scriptworker_beta_google_play_service_account_dev'),
            certificate => secret('pushapk_scriptworker_beta_google_play_certificate_dev'),
            certificate_target_location => "${pushapk_scriptworker_root}/beta.p12",
          },
          'release' => {
            service_account => secret('pushapk_scriptworker_release_google_play_service_account_dev'),
            certificate => secret('pushapk_scriptworker_release_google_play_certificate_dev'),
            certificate_target_location => "${pushapk_scriptworker_root}/release.p12",
          },
        },
      },
      'prod' => {
        provisioner_id => 'scriptworker-prov-v1',
        worker_group => 'pushapk-v1',
        worker_type => 'pushapk-v1',
        verbose_logging => true,
        taskcluster_client_id => secret('pushapk_scriptworker_taskcluster_client_id_prod'),
        taskcluster_access_token => secret('pushapk_scriptworker_taskcluster_access_token_prod'),
        google_play_config => {
          'aurora' => {
            service_account => secret('pushapk_scriptworker_aurora_google_play_service_account_prod'),
            certificate => secret('pushapk_scriptworker_aurora_google_play_certificate_prod'),
            certificate_target_location => "${pushapk_scriptworker_root}/aurora.p12",
          },
          'beta' => {
            service_account => secret('pushapk_scriptworker_beta_google_play_service_account_prod'),
            certificate => secret('pushapk_scriptworker_beta_google_play_certificate_prod'),
            certificate_target_location => "${pushapk_scriptworker_root}/beta.p12",
          },
          'release' => {
            service_account => secret('pushapk_scriptworker_release_google_play_service_account_prod'),
            certificate => secret('pushapk_scriptworker_release_google_play_certificate_prod'),
            certificate_target_location => "${pushapk_scriptworker_root}/release.p12",
          },
        },
      },
    }

    # Funsize Scheduler configuration
    $funsize_scheduler_root = "/builds/funsize"
    $funsize_scheduler_balrog_username = "funsize"
    $funsize_scheduler_pulse_username = "funsize"
    $funsize_scheduler_pulse_queue = "scheduler"
    $funsize_scheduler_bb_pulse_exchange = "exchange/build"
    $funsize_scheduler_tc_pulse_exchange = "exchange/taskcluster-queue/v1/task-completed"
    $funsize_scheduler_s3_bucket = "mozilla-nightly-updates"
    $funsize_scheduler_balrog_worker_api_root = "http://balrog/api"
    $funsize_scheduler_th_api_root = "https://treeherder.mozilla.org/api"
}
