# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org                   = 'moco'

    $puppet_notif_email    = 'releng-puppet-mail@mozilla.com'
    $puppet_relops_email   = 'relops-rejh-mail@mozilla.com'

    # what puppet report processors to use
    # http temporarily disabled in mdc1 and mdc2 until relops sets up a local foreman
    $puppet_server_reports = $::fqdn ? {
        /.*\.(mdc1|mdc2)\.mozilla\.com/      => 'tagmail',
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => 'tagmail,http',
        default => '',
    }

    # where to send http/https reports
    $puppet_server_reporturl = $::fqdn ? {
        /.*\.(mdc1|mdc2)\.mozilla\.com/      => '',
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => 'http://foreman.pvt.build.mozilla.org:3001/',
        default => '',
    }

    # where to store puppet facts
    # http temporarily disabled in mdc1 and mdc2 until relops sets up a local foreman
    $puppet_server_facturl = $::fqdn ? {
        /.*\.(mdc1|mdc2)\.mozilla\.com/      => '',
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => 'http://foreman.pvt.build.mozilla.org:3000/',
        default => '',
    }

    $builder_username                = 'cltbld'
    $install_google_api_key          = true
    $install_ceph_cfg                = true
    $install_mozilla_geoloc_api_keys = true
    $install_google_oauth_api_key    = true
    $install_crash_stats_api_token   = true
    $install_adjust_sdk_token        = true
    $install_relengapi_token         = true
    $install_release_s3_credentials  = true

    # we use the sort_servers_by_group function to sort the list of servers, and then just use
    # the first as the primary server
    $grouped_puppet_servers          = {
        '.*\.releng\.mdc1\.mozilla\.com' => [
            'releng-puppet1.srv.releng.mdc1.mozilla.com',
            'releng-puppet2.srv.releng.mdc1.mozilla.com',
        ],
        '.*\.releng\.mdc2\.mozilla\.com' => [
            'releng-puppet1.srv.releng.mdc2.mozilla.com',
            'releng-puppet2.srv.releng.mdc2.mozilla.com',
        ],
        '.*\.releng\.scl3\.mozilla\.com' => [
            'releng-puppet1.srv.releng.scl3.mozilla.com',
            'releng-puppet2.srv.releng.scl3.mozilla.com',
        ],
        '.*\.releng\.use1\.mozilla\.com' => [
            'releng-puppet1.srv.releng.use1.mozilla.com',
        ],
        '.*\.releng\.usw2\.mozilla\.com' => [
            'releng-puppet1.srv.releng.usw2.mozilla.com',
        ],
    }

    $puppet_servers = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server  = $puppet_servers[0]
    $data_servers   = $puppet_servers
    $data_server    = $puppet_server

    # Puppet masters CAs we deem valid
    $valid_puppet_cas = [
                          'releng-puppet1.srv.releng.mdc1.mozilla.com',
                          'releng-puppet2.srv.releng.mdc1.mozilla.com',
                          'releng-puppet1.srv.releng.mdc2.mozilla.com',
                          'releng-puppet2.srv.releng.mdc2.mozilla.com',
                          'releng-puppet1.srv.releng.scl3.mozilla.com',
#                          'releng-puppet2.srv.releng.scl3.mozilla.com',  # This intermediate CA is expiring on 2018/05/01, let's invalidate it until the cert is renewed
                          'releng-puppet1.srv.releng.use1.mozilla.com',
                          'releng-puppet1.srv.releng.usw2.mozilla.com',
                        ]

    $local_datacenter = $::fqdn ? {
        /^.*\.mdc1\.mozilla\.com$/ => 'mdc1',
        /^.*\.mdc2\.mozilla\.com$/ => 'mdc2',
        /^.*\.scl3\.mozilla\.com$/ => 'scl3',
        /^.*\.use1\.mozilla\.com$/ => 'use1',
        /^.*\.usw2\.mozilla\.com$/ => 'usw2',
        default                    => '',
    }

    $nearby_puppet_cas = grep($valid_puppet_cas, "^.*\\.${local_datacenter}\\.mozilla.com$")

    $node_location  = $::fqdn? {
        /.*\.(mdc1|mdc2|scl3)\.mozilla\.com/ => 'in-house',
        /.*\.(use1|usw2)\.mozilla\.com/      => 'aws',
        default => 'unknown',
    }

    # this is a round-robin DNS containing all of the moco puppet masters.  This is the
    # only way to communicate to apt that the masters are all mirrors of one another.
    # See https://bugzilla.mozilla.org/show_bug.cgi?id=906785
    $apt_repo_server            = 'puppetagain-apt.pvt.build.mozilla.org'
    $distinguished_puppetmaster = 'releng-puppet2.srv.releng.scl3.mozilla.com'
    $puppet_again_repo          = 'https://github.com/mozilla/build-puppet'
    $puppetmaster_extsyncs      = {
        'slavealloc' => {
            'slavealloc_api_url' => 'http://slavealloc.pvt.build.mozilla.org/api/',
        },
        'moco_ldap' => {
            'moco_ldap_uri'   => $::fqdn ? {
                        /.*\.mdc1\.mozilla\.com/             => 'ldap://ldap-slave.vips.private.mdc1.mozilla.com',
                        /.*\.mdc2\.mozilla\.com/             => 'ldap://ldap-slave.vips.private.mdc2.mozilla.com',
                        default                              => 'ldap://ldap.db.scl3.mozilla.com/',
                },
            'moco_ldap_root'  => 'dc=mozilla',
            'moco_ldap_dn'    => secret('moco_ldap_dn'),
            'moco_ldap_pass'  => secret('moco_ldap_pass'),
            'users_in_groups' => {
                'ldap_admin_users' => ['releng', 'relops'],
            },
        }
    }

    # include this name in the master certs so that apt can validate the SSH
    # connection
    $puppetmaster_cert_extra_names = [$apt_repo_server]

    $user_python_repositories      = [ 'https://pypi.pvt.build.mozilla.org/pub', 'https://pypi.pub.build.mozilla.org/pub' ]

    # Releng hosts are 'medium' by default.  Slaves are specifically overridden
    # with the 'low' level, and some others are flagged as 'high' or 'maximum'.
    $default_security_level        = 'medium'

    $nrpe_allowed_hosts            = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/             => '127.0.0.1,10.49.75.30',
        /.*\.mdc2\.mozilla\.com/             => '127.0.0.1,10.51.75.30',
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => '127.0.0.1,10.26.75.30',
        default                              => '127.0.0.1,10.26.75.30',
    }

    $ntp_servers                   = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/             => [ 'infoblox1.private.mdc1.mozilla.com' ],
        /.*\.mdc2\.mozilla\.com/             => [ 'infoblox1.private.mdc2.mozilla.com' ],
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => [ 'ns1.private.releng.scl3.mozilla.com',
                                                  'ns2.private.releng.scl3.mozilla.com',
                                                  'ns1.private.scl3.mozilla.com',
                                                  'ns2.private.scl3.mozilla.com',
                                                  'infoblox1.private.scl3.mozilla.com'],
        default                              => [ 'ns1.private.releng.scl3.mozilla.com',
                                                  'ns2.private.releng.scl3.mozilla.com',
                                                  'ns1.private.scl3.mozilla.com',
                                                  'ns2.private.scl3.mozilla.com',
                                                  'infoblox1.private.mdc1.mozilla.com'],
    }

    $relayhost                     = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/             => 'smtp1.private.mdc1.mozilla.com',
        /.*\.mdc2\.mozilla\.com/             => 'smtp1.private.mdc2.mozilla.com',
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => 'smtp.mail.scl3.mozilla.com',
        default                              => undef,
    }

    $enable_mig_agent                = true

    # Conditional puppet run at boot for Mac slaves
    case $::fqdn {
        /t-yosemite-r7-\d+\.test\.releng\.(scl3|mdc1|mdc2|usw2|use1)\.mozilla\.com/: {
            $puppet_run_atboot_if_more_than_n_reboots = 5
            $puppet_run_atboot_if_more_than_seconds   = 3600
        }
        default: {
        }
    }

    $signer_username                 = 'cltsign'
    $signing_tools_repo              = 'https://hg.mozilla.org/build/tools'
    $signing_mac_id                  = 'Mozilla'

    # NOTE: signing is also limited by a host level firewall
    # See modules/fw/manifests/networks.pp
    $signing_allowed_ips             = [
        '10.134.68.32/32', # dev-master2
        '10.26.48.41/32',  # partner-repack1
        '10.26.44.0/22',   # wintry.releng.scl3 (vlan 244)
        '10.26.52.0/22',   # build.releng.scl3 (vlan 252)
        '10.26.64.0/22',   # try.releng.scl3 (vlan 264)
        '10.132.52.0/22',  # build.releng.usw2
        '10.132.64.0/22',  # try.releng.usw2
        '10.134.52.0/22',  # build.releng.use1
        '10.134.64.0/22',  # try.releng.use1
        '10.134.164.0/24', # build.releng.use1
        '10.134.165.0/24', # try.releng.use1
        '10.26.68.0/24',   # bb.releng.scl3
        '10.132.68.0/24',  # bb.releng.usw2
        '10.134.68.0/24',  # bb.releng.use1
        '10.132.30.0/24',  # srv.releng.usw2 (signing)
        '10.134.30.0/24',  # srv.releng.use1 (signing)
    ]
    $signing_new_token_allowed_ips   = [
        '10.134.68.32/32', # dev-master2
        '10.26.48.41/32',  # partner-repack1
        '10.26.68.0/24',   # bb.releng.scl3
        '10.132.68.0/24',  # bb.releng.usw2
        '10.134.68.0/24',  # bb.releng.use1
        '10.132.30.0/24',  # srv.releng.usw2 (signing)
        '10.134.30.0/24',  # srv.releng.use1 (signing)
    ]

    $extra_user_ssh_keys             = {
        # role accounts

        # used on buildbot masters
        'release-runner' => [ 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCjq0iMalKswxR5xl0mQIMA0YdKVwxTidy4pA/IAN9e4OwOkk4iknvnfpzAft7F4erxDDWhETerqrVN7oVgCFtwXrLQ/OGDEFZg98dPXvMCn80+DqpKB8LlZXBf66B8UDfJJAlM2uvRsqKMCJP826k6aARmiYgKlTMUM4DR2+F7ArY/7OV4hfecx70q9hKK1ZmpMXIDQWDvcu6ltSYRmmPo4Qdzig1Yu9Yjl0KLsWHu+N5QP9McWfJ9QGYHlVsrlywjoweytwIWpFhnUIPh1OlD3YuGi9qs9pfKI4PDfKFa25FDDTLBh9RlUr0x4V1WKYDsvCr4+TKGb1gR4JGo6esZB+lx8QH+zwgxRamzst1pdM1WyFN+csyjHCX2AuWa2/qfLAJIglqXRcEfXEy26GclP6d1uRK4s2vCF9YmLO8FGbvqqlC1rg36pOjR8WGJAGY4eB1AsQSW1HKqvB2exDv+90FSV9iTmCE8aR3mxSLrE1zTJfeNn9x07UURtBStq83PMA8vUjRvKP0mLyKZ5Bpne3rNUO192g/6+4KAuOxrzS/70dlPzmtFhZOapsFcKsIAj3zlu7JGfwOt8ycOLLlH3pjQIKq3JUaO3FgiYXvEB92VhbDadngVJiiq+8VUlcGSFSrFMg6idx2Vu9EAs5zPjYCA5k1pKQ+340POr5oxHw== Releng RSA key release-runner on 2017-05-19' ],
        'aws-ssh-key'    => [ 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9iiSg20Kr4F/L9GfkJauYw15zxb8ND6zMrfoPha7nj2hzc+E7D8fzZzWyuSBFeH2N1LqJCMw0UQGhEX555iSmRk6Dn0tJQjM8pg27VbuYjNWpBH+Tdi34qyK/BWc36dNPF741paEiWZHqfq6HEMU/xjLRcUGXzjBFgx6hI/7bCd4Q8g+oD57tCxWtSPMoz7zan1eJUzPrw9T/EJCqVzjp5d6LIpMeCZ8n6xbaS8GmQk2fDxXpkVKHaxCPZ4i2tgVG5Bjei+Z451GgTgWmre/EbhbY8vtBs9UTyqmiioZX/2L3xOzqr3sArS4UPyJKSUKISDIOnyyKjzaWRkHciqBq6p15f+FfwaYLQXjfRapyGEfB/4O7t7Qt2E/2Xyi+LebIKS8PG1SKdNCL8vjeSZ6tQtAGQ6aKtQL285r28w3pdW5MIrhW5eafwGyqh0byGx6F04eqxyncWsA2EWkzpWwM9mDLRit3DrpeFMx0ikcMsDVpwJUTkUAQT/3la2EA6sn3MMijSc/nJIhvUoDbnxAZhmiCJgztTCXaPEpwNmvvYsa9urqll6TT/aI8hIL3CwQMAgcpNHS+hpiZrSuDyy9Ny+nUvT9fMlFYopTkmDL/D1XJT05osDqVEJgWkFaHfDn94iDWD6CTnUua0lWjuHqYpIZh1BpVsYZ/7HQrDJSKVw== Releng RSA key aws-releng on 2017-05-19' ],
    }
    $signing_server_ssl_private_keys = hiera_hash('signing_server_ssl_private_keys')
    $signing_server_ssl_certs        = hiera_hash('signing_server_ssl_certs')

    $jumphost_admin_users = [
        # a few folks from relops..
        'klibby',
        'jwatkins',
        'dhouse',
        'mcornmesser',
        'qfortier',
        'rthijssen',
        'dcrisan',
    ]

    # a few users from each team as the 'short list' of people with access
    $shortlist = [
        # a few folks from relops..
        'klibby',
        'jwatkins',
        'dhouse',

        # ..and a few folks from releng
        'asasaki',
        'bhearsum',
        'catlee',
        'jlorenzo',
        'jwood',
        'mtabara',
        'nthomas',
        'raliiev',
        'sfraser',
    ]

    $admin_users                     = $::fqdn ? {
        /^rejh\d\.srv\.releng\.(mdc1|mdc2|scl3)\.mozilla.com/  => $jumphost_admin_users,
        # signing machines have a very limited access list
        /^(mac-)?(v2-)?signing\d\..*/                          => $shortlist,
        /^signing-linux-\d\..*/                                => $shortlist,
        /^tb-signing-\d\..*/                                   => $shortlist,
        /signingworker-.*\.srv\.releng\..*\.mozilla\.com/      => $shortlist,
        default                                                => hiera('ldap_admin_users',
                                                                    # backup to ensure access in cas'e the sync fails:
                                                                    ['klibby', 'jwatkins'])
    }

    $jumphost_users = [
        'asasaki',
        'catlee',
        'jlorenzo',
        'jlund',
        'jwood',
        'mtabara',
        'nthomas',
        'raliiev',
        'rgarbas',
        'sfraser',
        'bhearsum', # Bug 1409806
        'bcrisan', # Bug 1434170
        'dlabici', # Bug 1434170
        'riman', # Bug 1434170
        'rmutter', # Bug 1434170
        'zfay', # Bug 1434170
        'apop', # Bug 1442124
        'acraciun', # Bug 1443668
        'tprince', # Bug 1449013
        'lguo', # Bug 1459746
    ]

    $users = $::fqdn ? {
        /^rejh\d\.srv\.releng\.(mdc1|mdc2|scl3)\.mozilla.com/  => $jumphost_users,
        default                                                => []
    }

    $buildbot_mail_to                 = 'release@mozilla.com'
    $master_json                      = 'https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json'

    $vmwaretools_version              = '10.0.9-3917699'
    $vmwaretools_md5                  = '160979c6d9f5b0979d81b3b6c15d0b1a'
    # These need to be in 'Foo <foo@bar.com>' style to work with release runner
    $releaserunner_notify_from        = 'Release Eng <release@mozilla.com>'
    $releaserunner_smtp_server        = 'localhost'
    $releaserunner_hg_host            = 'hg.mozilla.org'
    $releaserunner_hg_username        = 'ffxbld'
    $releaserunner_hg_ssh_key         = '/home/cltbld/.ssh/ffxbld_rsa'
    $releaserunner_production_masters = 'https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json'
    $releaserunner_sendchange_master  = 'buildbot-master81.build.mozilla.org:9301'
    $releaserunner_ssh_username       = 'cltbld'

    $releaserunner_env_config = {
        'dev' => {
            ship_it_root                          => 'https://ship-it-dev.allizom.org',
            ship_it_username                      => secret('releaserunner_dev_ship_it_username'),
            ship_it_password                      => secret('releaserunner_dev_ship_it_password'),
            notify_to                             => 'Release Notifications Dev <release-automation-notifications-dev@mozilla.com>',
            notify_to_announce                    => 'Release Notifications Dev <release-automation-notifications-dev@mozilla.com>',
            taskcluster_client_id                 => secret('releaserunner_dev_taskcluster_client_id'),
            taskcluster_access_token              => secret('releaserunner_dev_taskcluster_access_token'),
            balrog_username                       => 'balrog-stage-ffxbld',
            balrog_password                       => secret('balrog-stage-ffxbld_ldap_password'),
            beetmover_aws_access_key_id           => secret('stage-beetmover-aws_access_key_id'),
            beetmover_aws_secret_access_key       => secret('stage-beetmover-aws_secret_access_key'),
            releaserunner_buildbot_configs_branch => 'default',
            releaserunner_buildbot_configs        => 'https://hg.mozilla.org/build/buildbot-configs',
            releaserunner_gpg_key_path            => 'scripts/release/KEY',
            releaserunner_config_file             => 'release-runner.yml',
            allowed_branches                      => [ 'projects/jamun', 'projects/maple' ],
            firefox_pattern                       => 'Firefox-57.*',
            devedition_pattern                    => 'Devedition-57.*',
        },
        'prod-old' => {
            ship_it_root                          => 'https://ship-it.mozilla.org',
            ship_it_username                      => secret('releaserunner_prod_ship_it_username'),
            ship_it_password                      => secret('releaserunner_prod_ship_it_password'),
            notify_to                             => 'Release Notifications <release-automation-notifications@mozilla.com>',
            notify_to_announce                    => 'Release Signoff <release-signoff@mozilla.org>',
            taskcluster_client_id                 => secret('releaserunner_prod_taskcluster_client_id'),
            taskcluster_access_token              => secret('releaserunner_prod_taskcluster_access_token'),
            balrog_username                       => 'balrog-ffxbld',
            balrog_password                       => secret('balrog-ffxbld_ldap_password'),
            beetmover_aws_access_key_id           => secret('beetmover-aws_access_key_id'),
            beetmover_aws_secret_access_key       => secret('beetmover-aws_secret_access_key'),
            releaserunner_buildbot_configs_branch => 'production',
            releaserunner_buildbot_configs        => 'https://hg.mozilla.org/build/buildbot-configs',
            releaserunner_gpg_key_path            => 'scripts/release/KEY',
            releaserunner_config_file             => 'release-runner.ini',
        },
        'prod' => {
            ship_it_root                          => 'https://ship-it.mozilla.org',
            ship_it_username                      => secret('releaserunner_prod_ship_it_username'),
            ship_it_password                      => secret('releaserunner_prod_ship_it_password'),
            notify_to                             => 'Release Notifications <release-automation-notifications@mozilla.com>',
            notify_to_announce                    => 'Release Signoff <release-signoff@mozilla.org>',
            taskcluster_client_id                 => secret('releaserunner_prod_taskcluster_client_id'),
            taskcluster_access_token              => secret('releaserunner_prod_taskcluster_access_token'),
            balrog_username                       => 'balrog-ffxbld',
            balrog_password                       => secret('balrog-ffxbld_ldap_password'),
            beetmover_aws_access_key_id           => secret('beetmover-aws_access_key_id'),
            beetmover_aws_secret_access_key       => secret('beetmover-aws_secret_access_key'),
            releaserunner_buildbot_configs_branch => 'production',
            releaserunner_buildbot_configs        => 'https://hg.mozilla.org/build/buildbot-configs',
            releaserunner_gpg_key_path            => 'scripts/release/KEY',
            releaserunner_config_file             => 'release-runner.yml',
            allowed_branches                      => [
                                                        'releases/mozilla-release',
                                                        'releases/mozilla-beta',
                                                        'releases/mozilla-esr*',
                                                      ],
            firefox_pattern                       => 'Firefox-5[28].*',
            devedition_pattern                    => 'Devedition-58.*',
        }
    }

    $releaserunner3_env_config = {
        'dev' => {
            ship_it_root                          => 'https://ship-it-dev.allizom.org',
            ship_it_username                      => secret('releaserunner_dev_ship_it_username'),
            ship_it_password                      => secret('releaserunner_dev_ship_it_password'),
            notify_to                             => 'Release Notifications Dev <release-automation-notifications-dev@mozilla.com>',
            notify_to_announce                    => 'Release Notifications Dev <release-automation-notifications-dev@mozilla.com>',
            taskcluster_client_id                 => secret('releaserunner_dev_taskcluster_client_id'),
            taskcluster_access_token              => secret('releaserunner_dev_taskcluster_access_token'),
            github_token                          => secret('releaserunner_github_token'),
            eme_free_url                          => 'https://github.com/mozilla-partners/mozilla-EME-free-manifest',
            partner_repack_url                    => 'git@github.com:mozilla-partners/repack-manifests',
            partner_min_version                   => 61,
            releaserunner_config_file             => 'release-runner.yml',
            allowed_branches                      => [ 'projects/jamun', 'projects/maple', 'projects/birch' ],
            fennec_pattern                        => 'Fennec-.*',
            firefox_pattern                       => 'Firefox-(5[89]|6[0-9]).*',
            devedition_pattern                    => 'Devedition-(5[89]|6[0-9]).*',
            comm_allowed_branches                 => [ 'try-comm-central' ],
            thunderbird_pattern                   => 'Thunderbird-.*',
            shipitv2_api_root                     => 'https://shipit-workflow.staging.mozilla-releng.net',
            auth0_client_id                       => secret('releaserunner_auth0_client_id_dev'),
            auth0_client_secret                   => secret('releaserunner_auth0_client_secret_dev'),
            auth0_auth_domain                     => 'auth.mozilla.auth0.com',
            auth0_audience                        => 'https://shipit-workflow.staging.mozilla-releng.net/',
        },
        'prod' => {
            ship_it_root                          => 'https://ship-it.mozilla.org',
            ship_it_username                      => secret('releaserunner_prod_ship_it_username'),
            ship_it_password                      => secret('releaserunner_prod_ship_it_password'),
            notify_to                             => 'Release Notifications <release-automation-notifications@mozilla.com>',
            notify_to_announce                    => 'Release Signoff <release-signoff@mozilla.org>',
            taskcluster_client_id                 => secret('releaserunner_prod_taskcluster_client_id'),
            taskcluster_access_token              => secret('releaserunner_prod_taskcluster_access_token'),
            github_token                          => secret('releaserunner_github_token'),
            eme_free_url                          => 'https://github.com/mozilla-partners/mozilla-EME-free-manifest',
            partner_repack_url                    => 'git@github.com:mozilla-partners/repack-manifests',
            partner_min_version                   => 60,
            releaserunner_config_file             => 'release-runner.yml',
            allowed_branches                      => [
                                                        'releases/mozilla-release',
                                                        'releases/mozilla-beta',
                                                        'releases/mozilla-esr*',
                                                      ],
            fennec_pattern                        => 'Fennec-.*',
            firefox_pattern                       => 'Firefox-(5[9]|6[0-9]).*',
            devedition_pattern                    => 'Devedition-(5[9]|6[0-9]).*',
        }
    }


    $slaveapi_slavealloc_url           = 'http://slavealloc.build.mozilla.org/api/'
    $slaveapi_inventory_url            = 'https://inventory.mozilla.org/en-US/tasty/v3/'
    $slaveapi_inventory_username       = 'releng-inventory-automation'
    $slaveapi_buildapi_url             = 'http://buildapi.pvt.build.mozilla.org/buildapi/'
    $slaveapi_bugzilla_username        = 'slaveapi@mozilla.releng.tld'
    $slaveapi_default_domain           = 'build.mozilla.org'
    $slaveapi_ipmi_username            = 'releng'
    $slaveapi_bugzilla_dev_url         = 'https://bugzilla-dev.allizom.org/rest/'
    $slaveapi_bugzilla_prod_url        = 'https://bugzilla.mozilla.org/rest/'

    $selfserve_agent_sendchange_master = 'bm81-build_scheduler'
    $selfserve_agent_branches_json     = 'https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-branches.json'
    $selfserve_agent_masters_json      = 'https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json'
    $selfserve_agent_allthethings_json = 'https://secure.pub.build.mozilla.org/builddata/reports/allthethings.json'
    $selfserve_agent_clobberer_url     = 'https://api.pub.build.mozilla.org/clobberer/clobber/by-builder'
    $selfserve_agent_carrot_hostname   = 'releng-rabbitmq-zlb.webapp.scl3.mozilla.com'
    $selfserve_agent_carrot_vhost      = '/buildapi'
    $selfserve_agent_carrot_userid     = 'buildapi'
    $selfserve_agent_carrot_exchange   = 'buildapi.control'
    $selfserve_agent_carrot_queue      = 'buildapi-agent-rabbit2'
    $selfserve_private_url             = 'http://buildapi.pvt.build.mozilla.org/buildapi/self-serve'

    $distinguished_aws_manager         = 'aws-manager2.srv.releng.scl3.mozilla.com'
    $aws_manager_mail_to               = 'release+aws-manager@mozilla.com'
    $cloudtrail_s3_bucket              = 'mozilla-releng-aws-logs'
    $cloudtrail_s3_base_prefix         = 'AWSLogs/314336048151/CloudTrail'
    # this is the dev instance at least until bug 929584 is fixed
    $slaverebooter_slaveapi            = 'http://slaveapi1.srv.releng.scl3.mozilla.com:8080'
    $slaverebooter_mail_to             = 'release@mozilla.com'

    $buildmaster_ssh_keys              = [ 'ffxbld_rsa', 'tbirdbld_dsa', 'trybld_dsa' ]

    case $::fqdn {
        /.*\.mdc1\.mozilla\.com/: {
                $collectd_write = {
                    graphite_nodes => {
                        'graphite1.private.mdc1.mozilla.com' => {
                            'port' => '2003', 'prefix' => 'hosts.',
                        },
                    },
                }
        }
        /.*\.mdc2\.mozilla\.com/: {
                $collectd_write = {
                    graphite_nodes => {
                        'graphite1.private.mdc2.mozilla.com' => {
                            'port' => '2003', 'prefix' => 'hosts.',
                        },
                    },
                }
        }
        /.*\.scl3\.mozilla\.com/: {
                $collectd_write                    = {
                    graphite_nodes => {
                        'graphite-relay.private.scl3.mozilla.com' => {
                            'port' => '2003', 'prefix' => 'hosts.',
                        },
                    },
                }
        }
    }

    #### start configuration information for rsyslog logging

    # cef server for auditd output
    $cef_syslog_server = $::fqdn ? {
        /.*\.mdc1\.mozilla\.com/             => 'syslog1.private.mdc1.mozilla.com',
        /.*\.mdc2\.mozilla\.com/             => 'syslog1.private.mdc2.mozilla.com',
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => 'syslog1.private.scl3.mozilla.com',
        default => '',
    }

    # log aggregator settings per location/region
    #
    # note that the log aggregation file is overwritten via cloud-init in AWS
    # because the golden AMIs we generate are done in use1 and always specify
    # log-aggregator.srv.releng.use1.mozilla.com even for usw2 hosts
    # See https://github.com/mozilla/build-cloud-tools/pull/45

    $log_aggregator    = $::fqdn ? {
        /.*\.mdc1\.mozilla\.com/ => 'log-aggregator.srv.releng.mdc1.mozilla.com',
        /.*\.mdc2\.mozilla\.com/ => 'log-aggregator.srv.releng.mdc2.mozilla.com',
        /.*\.scl3\.mozilla\.com/ => 'log-aggregator.srv.releng.scl3.mozilla.com',
        /.*\.use1\.mozilla\.com/ => 'log-aggregator.srv.releng.use1.mozilla.com',
        /.*\.usw2\.mozilla\.com/ => 'log-aggregator.srv.releng.usw2.mozilla.com',
        default => '',
    }

    # we need to pick a logging port > 1024 for AWS to use the ELB
    $logging_port = $::fqdn ? {
        /.*\.(mdc1|mdc2|scl3)\.mozilla\.com/ => '514',
        /.*\.(usw2|use1)\.mozilla\.com/      => '1514',
        default => '',
    }

    #### end configuration information for rsyslog logging

    # runner task settings
    $runner_hg_tools_path          = '/tools/checkouts/build-tools'
    $runner_hg_tools_repo          = 'https://hg.mozilla.org/build/tools'
    $runner_hg_tools_branch        = 'default'
    $runner_hg_mozharness_path     = '/tools/checkouts/mozharness'
    $runner_hg_mozharness_repo     = 'https://hg.mozilla.org/build/mozharness'
    $runner_hg_mozharness_branch   = 'production'

    $runner_env_hg_share_base_dir  = '/builds/hg-shared'
    $runner_env_git_share_base_dir = '/builds/git-shared'

    $runner_buildbot_slave_dir     = '/builds/slave'
    $runner_clobberer_url          = 'https://api.pub.build.mozilla.org/clobberer/lastclobber/all'

    # deploystudio
    $deploystudio_username         = 'dsadmin'
    # deploystudio_uid must be an int greater than 500
    $deploystudio_uid              = 543647
    # deploystudio root data directory
    $deploystudio_dir              = '/Deploy'

    $xcode_version = $::macosx_productversion_major ? {
        10.7    => '4.1',
        10.8    => '5.1-cmdline',
        10.9    => '5.0-cmdline',
        10.10   => $::fqdn ? {
            /t-yosemite-r7-\d+\.test\.releng\.(scl3|mdc1|mdc2)\.mozilla\.com/ => '6.1-cmdline',
            default                                                           => '6.1',
            },
        default => undef
    }

    # When specifying the Ununtu current kernel, you must use the fully qualified version of the package
    # The format is aa.bb.xx.yy.zz You can find this with 'dpkg -I linux-generic.deb'
    $current_kernel = $::operatingsystem ? {
        'CentOS' => $::operatingsystemrelease ? {
            '6.2'   => '2.6.32-504.3.3.el6',
            '6.5'   => '2.6.32-642.13.1.el6',
            default => undef,
        },
        'Ubuntu' => $::operatingsystemrelease ? {
            '12.04' => '3.2.0.76.90',
            '14.04' => '3.13.0.45.52',
            '16.04' => '4.4.0.66.70',
            default => undef,
        },
        default  => undef,
    }

    # Specifying Ubuntu obsolete kernels is a different format than current kernel above
    # The format is aa.bb.xx-yy
    $obsolete_kernels = $::operatingsystem ? {
        'CentOS' => $::operatingsystemrelease ? {
            '6.2'   => [ '2.6.32-431.el6', '2.6.32-431.11.2.el6', '2.6.32-431.5.1.el6' ],
            '6.5'   => [ '2.6.32-431.el6', '2.6.32-431.11.2.el6', '2.6.32-431.5.1.el6', '2.6.32-504.3.3.el6' ],
            default => [],
        },
        'Ubuntu' => $::operatingsystemrelease ? {
            '12.04' => [ '3.2.0-75', '3.2.0-38', '3.5.0-18'],
            '14.04' => [ '3.13.0-27', '3.13.0-44' ],
            default => [],
        },
        default => [],
    }

    # bacula configuration
    $bacula_director = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/             => 'bacula1.private.mdc1.mozilla.com',
        /.*\.mdc2\.mozilla\.com/             => 'bacula1.private.mdc2.mozilla.com',
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => 'bacula1.private.scl3.mozilla.com',
        default => undef,
    }

    $bacula_fd_port                                     = 9102
    # this isn't actually secret, but it's long, so we stick it in hiera.
    $bacula_cacert = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/             => secret('bacula_mdc1_ca_cert'),
        /.*\.mdc2\.mozilla\.com/             => secret('bacula_mdc2_ca_cert'),
        /.*\.(scl3|usw2|use1)\.mozilla\.com/ => secret('bacula_scl3_ca_cert'),
        default => undef,
    }

    # Bug 1394481. old bacula in scl3 without PKI
    $bacula_pki_enabled = $::fqdn ? {
        /.*\.scl3\.mozilla\.com/ => false,
        default                  => true,
    }

    # Buildbot <-> Taskcluster bridge configuration
    $buildbot_bridge_root                               = '/builds/bbb'
    $buildbot_bridge_tclistener_pulse_exchange_basename = 'exchange/taskcluster-queue/v1'
    $buildbot_bridge_worker_type                        = 'buildbot-bridge'
    $buildbot_bridge_provisioner_id                     = 'buildbot-bridge'
    $buildbot_bridge_bblistener_pulse_exchange          = 'exchange/build'
    $buildbot_bridge_worker_group                       = 'buildbot-bridge'
    $buildbot_bridge_worker_id                          = 'buildbot-bridge'
    $buildbot_bridge_reflector_interval                 = 60

    $buildbot_bridge_env_config = {
        'dev'  => {
            version              => '1.6.5',
            client_id            => secret('buildbot_bridge_dev_taskcluster_client_id'),
            access_token         => secret('buildbot_bridge_dev_taskcluster_access_token'),
            dburi                => secret('buildbot_bridge_dev_dburi'),
            pulse_username       => secret('buildbot_bridge_dev_pulse_username'),
            pulse_password       => secret('buildbot_bridge_dev_pulse_password'),
            pulse_queue_basename => 'queue/buildbot-bridge-dev',
            restricted_builders  => [
                '^release-.*$',
            ],
            ignored_builders     => [
                '^((?!(alder|birch|-date|jamun|maple)).)*$',
            ],
        },
        'prod' => {
            version              => '1.6.5',
            client_id            => secret('buildbot_bridge_prod_taskcluster_client_id'),
            access_token         => secret('buildbot_bridge_prod_taskcluster_access_token'),
            dburi                => secret('buildbot_bridge_prod_dburi'),
            pulse_username       => secret('buildbot_bridge_prod_pulse_username'),
            pulse_password       => secret('buildbot_bridge_prod_pulse_password'),
            pulse_queue_basename => 'queue/buildbot-bridge',
            restricted_builders  => [
                '^release-.*$',
            ],
            ignored_builders     => [
                '^.*alder.*$',
                '^.*birch.*$',
                '^.*jamun.*$',
                '^.*-date.*$',
                '^.*maple.*$',
            ],
        }
    }

    # Buildbot Bridge 2 configuration
    $buildbot_bridge2_root                        = '/builds/bbb2'
    $buildbot_bridge2_reflector_poll_interval     = 60
    $buildbot_bridge2_reflector_reclaim_threshold = 600

    $buildbot_bridge2_env_config = {
        'dev' => {
            version               => '2.0.0',
            client_id             => secret('buildbot_bridge2_dev_taskcluster_client_id'),
            access_token          => secret('buildbot_bridge2_dev_taskcluster_access_token'),
            dburi                 => secret('buildbot_bridge2_dev_dburi'),
            selfserve_private_url => 'http://buildapi.pvt.build.mozilla.org/buildapi/self-serve',
        },
        'prod' => {
            version               => '2.0.0',
            client_id             => secret('buildbot_bridge2_prod_taskcluster_client_id'),
            access_token          => secret('buildbot_bridge2_prod_taskcluster_access_token'),
            dburi                 => secret('buildbot_bridge2_prod_dburi'),
            selfserve_private_url => 'http://buildapi.pvt.build.mozilla.org/buildapi/self-serve',
        }
    }

    # TC host-secrets
    $tc_host_secrets_servers = $::fqdn ? {
        /.*\.(mdc1|mdc2|scl3)\.mozilla\.com/  => [
            "tc-host-secrets1.srv.releng.${1}.mozilla.com",
            "tc-host-secrets2.srv.releng.${1}.mozilla.com"
        ],
        default => '',
    }

    # TC signing workers
    $signingworker_exchange                   = 'exchange/taskcluster-queue/v1/task-pending'
    $signingworker_worker_type                = 'signing-worker-v1'

    # scriptworker
    $scriptworker_root                        = '/builds/scriptworker' # Used by scriptworker instances
    $scriptworker_gpg_private_keys            = hiera_hash('scriptworker_gpg_private_keys')
    $scriptworker_gpg_public_keys             = hiera_hash('scriptworker_gpg_public_keys')

    $l10n_bumper_env_config = {
        'mozilla-central' => {
            mozharness_repo     => 'https://hg.mozilla.org/mozilla-central',
            mozharness_revision => 'b159a6ed52f7',
            config_file         => 'l10n_bumper/mozilla-central.py',
        },
        'mozilla-beta'    => {
            mozharness_repo     => 'https://hg.mozilla.org/mozilla-central',
            mozharness_revision => '9c2f023a62d0',
            config_file         => 'l10n_bumper/mozilla-beta.py',
        },
    }
}
