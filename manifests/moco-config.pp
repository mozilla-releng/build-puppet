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
        /.*\.(usw2|use1|mdc1|mdc2)\.mozilla\.com/ => 'tagmail',
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
                          'releng-puppet1.srv.releng.use1.mozilla.com',
                          'releng-puppet1.srv.releng.usw2.mozilla.com',
                        ]

    $local_datacenter = $::fqdn ? {
        /^.*\.mdc1\.mozilla\.com$/ => 'mdc1',
        /^.*\.mdc2\.mozilla\.com$/ => 'mdc2',
        /^.*\.use1\.mozilla\.com$/ => 'use1',
        /^.*\.usw2\.mozilla\.com$/ => 'usw2',
        default                    => '',
    }

    $nearby_puppet_cas = grep($valid_puppet_cas, "^.*\\.${local_datacenter}\\.mozilla.com$")

    $node_location  = $::fqdn? {
        /.*\.(mdc1|mdc2)\.mozilla\.com/ => 'in-house',
        /.*\.(use1|usw2)\.mozilla\.com/      => 'aws',
        default => 'unknown',
    }

    # this is a round-robin DNS containing all of the moco puppet masters.  This is the
    # only way to communicate to apt that the masters are all mirrors of one another.
    # See https://bugzilla.mozilla.org/show_bug.cgi?id=906785
    $apt_repo_server            = 'puppetagain-apt.pvt.build.mozilla.org'
    $distinguished_puppetmaster = 'releng-puppet2.srv.releng.mdc1.mozilla.com'
    $puppet_again_repo          = 'https://github.com/mozilla-releng/build-puppet'
    $puppetmaster_extsyncs      = {
        'slavealloc' => {
            'slavealloc_api_url' => 'http://slavealloc.pvt.build.mozilla.org/api/',
        },
        'moco_ldap' => {
            'moco_ldap_uri'   => $::fqdn ? {
                        /.*\.mdc1\.mozilla\.com/ => 'ldap://ldap-slave.vips.private.mdc1.mozilla.com',
                        /.*\.mdc2\.mozilla\.com/ => 'ldap://ldap-slave.vips.private.mdc2.mozilla.com',
                        default                  => 'ldap://ldap-slave.vips.private.mdc1.mozilla.com',
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

    $user_python_repositories      = [ 'https://pypi.pub.build.mozilla.org/pub', ]

    # Releng hosts are 'medium' by default.  Slaves are specifically overridden
    # with the 'low' level, and some others are flagged as 'high' or 'maximum'.
    $default_security_level        = 'medium'

    $nrpe_allowed_hosts            = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/        => '127.0.0.1,10.49.75.30',
        /.*\.mdc2\.mozilla\.com/        => '127.0.0.1,10.51.75.30',
        /.*\.(usw2|use1)\.mozilla\.com/ => '127.0.0.1,10.49.75.30,10.51.75.30',
        default                         => '127.0.0.1',
    }

    $ntp_servers                   = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/        => [ 'infoblox1.private.mdc1.mozilla.com' ],
        /.*\.mdc2\.mozilla\.com/        => [ 'infoblox1.private.mdc2.mozilla.com' ],
        /.*\.(usw2|use1)\.mozilla\.com/ => [ 'infoblox1.private.mdc1.mozilla.com'],
        default                         => [ 'infoblox1.private.mdc1.mozilla.com'],
    }

    $relayhost                     = $::fqdn? {
        /.*\.(usw2|mdc1)\.mozilla\.com/ => 'smtp1.private.mdc1.mozilla.com',
        /.*\.(use1|mdc2)\.mozilla\.com/ => 'smtp1.private.mdc2.mozilla.com',
        default                         => undef,
    }

    $enable_mig_agent                = true

    # Conditional puppet run at boot for Mac slaves
    case $::fqdn {
        /t-yosemite-r7-\d+\.test\.releng\.(mdc1|mdc2|usw2|use1)\.mozilla\.com/: {
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
        '10.132.30.0/24',  # srv.releng.usw2 (signing scriptworkers)
        '10.134.30.0/24',  # srv.releng.use1 (signing scriptworkers)
    ]
    $signing_new_token_allowed_ips   = [
        '10.132.30.0/24',  # srv.releng.usw2 (signing scriptworkers)
        '10.134.30.0/24',  # srv.releng.use1 (signing scriptworkers)
    ]

    $mac_netboot_ips = [ '10.49.56.16',  # install.test.releng.mdc1
                        '10.51.56.16' ] # install.test.releng.mdc2

    # Copied from fw::networks
    $roller_ips = [ '10.49.48.75',  # roller1.srv.releng.mdc1.mozilla.com
                    '10.49.48.76',  # roller-dev1.srv.releng.mdc1.mozilla.com
                    '10.51.48.75',  # roller1.srv.releng.mdc2.mozilla.com
                    '10.51.48.76' ] # roller-dev1.srv.releng.mdc2.mozilla.com
    $roller_key_limits = join(['from="', join($roller_ips, ','), '",command="~/.ssh/allowed_commands.sh",',
                              'no-pty,no-port-forwarding,no-X11-forwarding,no-agent-forwarding,no-user-rc' ])

    $roller_image_tag_prod = '1.0.13'

    $extra_user_ssh_keys = {
        # role accounts

        # hardware controller
        'roller_ssh_pub_key' => [ "${roller_key_limits} ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDkgMMlWHbReAix1HaCdWzUkGrT7gGrV++uLDEm9HQH6NjYM1i0zh+RwCEGduJs9yuDLxvznpI9HkQWPgNLPRl7Bh8TQI2lAgnjFegOLNwGZyXrbLeQsDATFQnPY/alJE//c9yCzs59PENyjtfU4VF6tG8m8F6/kcNxJxQ4b07q/aPqQR+Aeg5i0MbXgULgjVgWbYlQ8lV+8P1UY1RGric0TIKM3Q1JGs0zvOxdgEvOX2HcEHePCEwKE4hZXvJnkC2wTCjy9+ppkanh2dM5i2UT7Z520dwKX0kX7O30Luv9ln3SflIF4nEGwHrbJfGerHdhJXbyRuctYrVoSj5CYdnFLYiAxTSVc+dbPkeOts7X5QghE6pLRwUFz4CBktR0Vrn8u00enyl6Ae95Rl+ut0P5yyLCJ78nBRroLE6TyuK1jsxVeSZv2WNx9tZTbSCkv3+xF56sRKpIs2jDAQKM3LsR5iNVauixsI7Q3QUSPuxDATY7zmwhKe2O3euhTN/tWfub+4GibzF64vaMZhkZaR5JF2kWK3tj1O/kbhwmeWQqTp08TcIk3YoWQjEClOO794mNGuLoWwd5WWPjq9mCKZ5qzUiWNpJxhcjJZETSaLHEn8ChtC+QxBrdc1DBxXfwvVznwu6L3LfAVHKaHtMaEOw+Y59bZktsVm0bd6OXazPxKQ== roller ssh key 2018-04-26" ],

        # used on buildbot masters
        'aws-ssh-key'    => [ 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9iiSg20Kr4F/L9GfkJauYw15zxb8ND6zMrfoPha7nj2hzc+E7D8fzZzWyuSBFeH2N1LqJCMw0UQGhEX555iSmRk6Dn0tJQjM8pg27VbuYjNWpBH+Tdi34qyK/BWc36dNPF741paEiWZHqfq6HEMU/xjLRcUGXzjBFgx6hI/7bCd4Q8g+oD57tCxWtSPMoz7zan1eJUzPrw9T/EJCqVzjp5d6LIpMeCZ8n6xbaS8GmQk2fDxXpkVKHaxCPZ4i2tgVG5Bjei+Z451GgTgWmre/EbhbY8vtBs9UTyqmiioZX/2L3xOzqr3sArS4UPyJKSUKISDIOnyyKjzaWRkHciqBq6p15f+FfwaYLQXjfRapyGEfB/4O7t7Qt2E/2Xyi+LebIKS8PG1SKdNCL8vjeSZ6tQtAGQ6aKtQL285r28w3pdW5MIrhW5eafwGyqh0byGx6F04eqxyncWsA2EWkzpWwM9mDLRit3DrpeFMx0ikcMsDVpwJUTkUAQT/3la2EA6sn3MMijSc/nJIhvUoDbnxAZhmiCJgztTCXaPEpwNmvvYsa9urqll6TT/aI8hIL3CwQMAgcpNHS+hpiZrSuDyy9Ny+nUvT9fMlFYopTkmDL/D1XJT05osDqVEJgWkFaHfDn94iDWD6CTnUua0lWjuHqYpIZh1BpVsYZ/7HQrDJSKVw== Releng RSA key aws-releng on 2017-05-19' ],
    }
    $signing_server_ssl_private_keys = secret('signing_server_ssl_private_keys')
    $signing_server_ssl_certs        = secret('signing_server_ssl_certs')

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

    $mobile_shortlist = [
        # relops
        'klibby',
        'jwatkins',
        'dhouse',

        # releng
        'asasaki',
        'bhearsum',
        'catlee',
        'jlorenzo',
        'jwood',
        'mhentges',
        'mtabara',
        'nthomas',
        'raliiev',
        'sfraser',
    ]

    $admin_users                     = $::fqdn ? {
        /^rejh\d\.srv\.releng\.(mdc1|mdc2)\.mozilla.com/  => $jumphost_admin_users,
        # signing machines have a very limited access list
        /^(dep-m|mobil)-signing.*/                             => $mobile_shortlist,
        /^(?!(dep-m|mobil)-signing).*sign.*/                   => $shortlist,
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
        'pmoore', # Bug 1492400
        'mhentges', # Bug 1509144
    ]

    $users = $::fqdn ? {
        /^rejh\d\.srv\.releng\.(mdc1|mdc2)\.mozilla.com/  => $jumphost_users,
        default                                                => []
    }

    $buildbot_mail_to                 = 'release@mozilla.com'
    $master_json                      = 'https://hg.mozilla.org/build/tools/raw-file/default/buildfarm/maintenance/production-masters.json'

    $vmwaretools_version              = '10.0.9-3917699'
    $vmwaretools_md5                  = '160979c6d9f5b0979d81b3b6c15d0b1a'

    $slaveapi_slavealloc_url           = 'http://slavealloc.build.mozilla.org/api/'
    $slaveapi_inventory_url            = 'https://inventory.mozilla.org/en-US/tasty/v3/'
    $slaveapi_inventory_username       = 'releng-inventory-automation'
    $slaveapi_buildapi_url             = 'http://buildapi.pvt.build.mozilla.org/buildapi/'
    $slaveapi_bugzilla_username        = 'slaveapi@mozilla.releng.tld'
    $slaveapi_default_domain           = 'build.mozilla.org'
    $slaveapi_ipmi_username            = 'releng'
    $slaveapi_bugzilla_dev_url         = 'https://bugzilla-dev.allizom.org/rest/'
    $slaveapi_bugzilla_prod_url        = 'https://bugzilla.mozilla.org/rest/'

    $aws_manager_mail_to               = 'release+aws-manager@mozilla.com'
    $cloudtrail_s3_bucket              = 'mozilla-releng-aws-logs'
    $cloudtrail_s3_base_prefix         = 'AWSLogs/314336048151/CloudTrail'

    $buildmaster_ssh_keys              = [ 'ffxbld_rsa', 'tbirdbld_dsa', 'trybld_dsa' ]

    case $::fqdn {
        /.*\.(mdc1|use1|usw2)\.mozilla\.com/: {
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
    }

    #### start configuration information for rsyslog logging

    # cef server for auditd output
    $cef_syslog_server = $::fqdn ? {
        /.*\.mdc1\.mozilla\.com/        => 'syslog1.private.mdc1.mozilla.com',
        /.*\.mdc2\.mozilla\.com/        => 'syslog1.private.mdc2.mozilla.com',
        /.*\.(usw2|use1)\.mozilla\.com/ => 'syslog1.private.mdc1.mozilla.com',
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
        /.*\.use1\.mozilla\.com/ => 'log-aggregator.srv.releng.use1.mozilla.com',
        /.*\.usw2\.mozilla\.com/ => 'log-aggregator.srv.releng.usw2.mozilla.com',
        default => '',
    }

    # we need to pick a logging port > 1024 for AWS to use the ELB
    $logging_port = $::fqdn ? {
        /.*\.(mdc1|mdc2)\.mozilla\.com/ => '514',
        /.*\.(usw2|use1)\.mozilla\.com/ => '1514',
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
            /t-yosemite-r7-\d+\.test\.releng\.(mdc1|mdc2)\.mozilla\.com/ => '6.1-cmdline',
            default                                                      => '6.1',
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
        default => undef,
    }

    $bacula_fd_port                                     = 9102
    # this isn't actually secret, but it's long, so we stick it in hiera.
    $bacula_cacert = $::fqdn? {
        /.*\.mdc1\.mozilla\.com/             => secret('bacula_mdc1_ca_cert'),
        /.*\.mdc2\.mozilla\.com/             => secret('bacula_mdc2_ca_cert'),
        default => undef,
    }

    $bacula_pki_enabled = true

    # TC signing workers
    $signingworker_exchange                   = 'exchange/taskcluster-queue/v1/task-pending'
    $signingworker_worker_type                = 'signing-worker-v1'

    # scriptworker
    $scriptworker_root                        = '/builds/scriptworker' # Used by scriptworker instances
    $scriptworker_gpg_private_key             = secret('scriptworker_gpg_private_key')
    $scriptworker_gpg_public_key              = secret('scriptworker_gpg_public_key')
    $scriptworker_ed25519_private_key         = secret('scriptworker_ed25519_private_key')

    $l10n_bumper_env_config = {
        'mozilla-central' => {
            mozharness_repo     => 'https://hg.mozilla.org/mozilla-central',
            mozharness_revision => 'fdceb5ba6e8c542945e20c1554720160f3247838',
            config_file         => 'l10n_bumper/mozilla-central.py',
        },
        'mozilla-beta'    => {
            mozharness_repo     => 'https://hg.mozilla.org/mozilla-central',
            mozharness_revision => 'fdceb5ba6e8c542945e20c1554720160f3247838',
            config_file         => 'l10n_bumper/mozilla-beta.py',
        },
    }
}
