# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class config inherits config::base {
    $org = 'qa'

    $puppet_notif_email                 = 'hskupin@mozilla.com'
    $puppet_server_reports              = 'tagmail'
    $builder_username                   = 'mozauto'
    $grouped_puppet_servers             = {
        '.*' => [
            'puppetmaster1.qa.scl3.mozilla.com',
        ],
    }
    $puppet_servers                     = sort_servers_by_group($grouped_puppet_servers)
    $puppet_server                      = $puppet_servers[0]
    $data_servers                       = $puppet_servers
    $data_server                        = $puppet_server

    $distinguished_puppetmaster         = 'puppetmaster1.qa.scl3.mozilla.com'
    $puppet_again_repo                  = 'https://hg.mozilla.org/qa/puppet/'

    $puppetmaster_upstream_rsync_source = 'rsync://puppetagain.pub.build.mozilla.org/data/'
    $puppetmaster_extsyncs              = {
        'moco_ldap' => {
            'moco_ldap_uri'   => 'ldap://ldap.db.scl3.mozilla.com/',
            'moco_ldap_root'  => 'dc=mozilla',
            'moco_ldap_dn'    => secret('moco_ldap_dn'),
            'moco_ldap_pass'  => secret('moco_ldap_pass'),
            'users_in_groups' => {
                'ldap_infra_users' => ['relops',
                    'netops', 'team_dcops', 'team_opsec', 'team_moc', 'team_infra', 'team_storage'],
            },
        }
    }

    $ntp_servers                        = [ 'ns1.private.scl3.mozilla.com', 'ns2.private.scl3.mozilla.com' ]
    $enable_mig_agent                   = true

    $web_proxy_host                     = 'proxy.dmz.scl3.mozilla.com'
    $web_proxy_port                     = '3128'
    $web_proxy_exceptions               = [ 'localhost', '127.0.0.1', 'localaddress',
                                            '.localdomain.com', '10.0.0.0/8',
                                            '.scl3.mozilla.com', '.phx1.mozilla.com', '.mozqa.com',
                                            'mm-ci-master', 'mm-ci-staging', 'db1',
                                            'puppet', 'repos' ]

    $vmwaretools_version                = '9.4.0-1280544'
    $vmwaretools_md5                    = '4a2d230828919048c0c3ae8420f8edfe'

    $admin_users                        = unique(concat([
            # Admins of the QA org
            'andrei.eftimie',  # previously aeftimie
            'andreea.matei',  # previously amatei
            'cosmin.malutan',  # previously cmalutan
            'ctalbert',
            'daniel.gherasim',  # previously dgherasim
            'hskupin'
        ],
        hiera('ldap_infra_users',
            # backup to ensure access in case the sync fails:
            ['arr', 'dmitchell', 'jwatkins'])))
}
