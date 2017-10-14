# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org                                = 'relabs'

    $puppet_notif_email                 = 'releng-puppet-mail@mozilla.com'
    $builder_username                   = 'relabsbld'
    $grouped_puppet_servers             = {
        '.*' => [
            'relabs-puppet2.relabs.releng.scl3.mozilla.com',
        ],
    }
    $puppet_servers                     = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server                      = $puppet_servers[0]
    $data_servers                       = $puppet_servers
    $data_server                        = $puppet_server
    $apt_repo_server                    = $data_server

    $distinguished_puppetmaster         = 'relabs-puppet2.relabs.releng.scl3.mozilla.com'
    $puppet_again_repo                  = 'https://hg.mozilla.org/build/puppet/'

    $puppet_server_reports              = 'http'
    $puppet_server_reporturl            = 'http://foreman.pvt.build.mozilla.org:3001/'
    $puppet_server_facturl              = 'http://foreman.pvt.build.mozilla.org:3000/'
    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppetmaster_extsyncs = {
        'slavealloc' => {
            'slavealloc_api_url' => 'http://slavealloc.pvt.build.mozilla.org/api/',
        },
        'moco_ldap'  => {
            'moco_ldap_uri'   => 'ldap://ldap.db.scl3.mozilla.com/',
            'moco_ldap_root'  => 'dc=mozilla',
            'moco_ldap_dn'    => secret('moco_ldap_dn'),
            'moco_ldap_pass'  => secret('moco_ldap_pass'),
            'users_in_groups' => {
                'ldap_admin_users' => ['releng', 'relops',
                'netops', 'team_dcops', 'team_opsec', 'team_moc', 'team_infra', 'team_storage'],
            },
        }
    }

    $signer_username                    = 'relabssign'
    $signing_tools_repo                 = 'https://hg.mozilla.org/build/tools'
    $signing_redis_host                 = 'localhost'
    $signing_mac_id                     = 'Relabs'
    $signing_allowed_ips                = [
        '10.250.48.0/22',
        '10.26.78.0/24',
    ]
    $signing_new_token_allowed_ips      = [
        '10.250.48.1', # fake
    ]

    $vmwaretools_version                = '9.4.0-1280544'
    $vmwaretools_md5                    = '4a2d230828919048c0c3ae8420f8edfe'

    $ntp_servers                        = [ 'ns1.private.releng.scl3.mozilla.com', 'ns2.private.releng.scl3.mozilla.com' ]
    $enable_mig_agent                   = true

    $admin_users                        = [
        'bhearsum',
        'catlee',
        'dmitchell',
        'jwatkins',
        'jwood',
        'raliiev',
        'cknowles',
        'dmaher',
        'hskupin',
        'pchiasson',
        'jvehent',
    ]

    # When specifying the Ununtu current kernel, you must use the fully qualified version of the package
    # The format is aa.bb.xx.yy.zz You can find this with 'dpkg -I linux-generic.deb'
    $current_kernel                     = $::operatingsystem ? {
        'CentOS' => $::operatingsystemrelease ? {
            '6.2'   => '2.6.32-504.3.3.el6',
            '6.5'   => '2.6.32-504.3.3.el6',
            default => undef,
        },
        'Ubuntu' => $::operatingsystemrelease ? {
            '12.04' => '3.2.0.76.90',
            '14.04' => '3.13.0.45.52',
            default => undef,
        },
        default  => undef,
    }

    # Specifying Ubuntu obsolete kernels is a different format than current kernel above
    # The format is aa.bb.xx-yy
    $obsolete_kernels                   = $::operatingsystem ? {
        'CentOS' => $::operatingsystemrelease ? {
            '6.2'   => [ '2.6.32-431.el6', '2.6.32-431.11.2.el6', '2.6.32-431.5.1.el6' ],
            '6.5'   => [ '2.6.32-431.el6', '2.6.32-431.11.2.el6', '2.6.32-431.5.1.el6' ],
            default => [],
        },
        'Ubuntu' => $::operatingsystemrelease ? {
            '12.04' => [ '3.2.0-75', '3.2.0-38' ],
            '14.04' => [ '3.13.0-27', '3.13.0-44' ],
            default => [],
        },
        default  => [],
    }
}

