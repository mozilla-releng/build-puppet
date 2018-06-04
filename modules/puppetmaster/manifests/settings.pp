# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::settings {
    include ::config

    $data_root                = '/data'
    $puppetmaster_root        = '/var/lib/puppetmaster'
    $puppetsync_home          = '/var/lib/puppetsync-home'
    $deploy_dir               = '/var/lib/puppetmaster/deploy'
    $pip2_download_virtualenv = '/etc/puppet/pip2-venv'
    $pip3_download_virtualenv = '/etc/puppet/pip3-venv'

    # how often to check and update the puppet manifests and files
    $puppet_check_interval_mins = 5
    $puppet_check_splay_secs    = 200

    # copy some useful values from config to this module
    $all_masters           = $::config::puppet_servers
    $distinguished_master  = $::config::distinguished_puppetmaster
    $upstream_rsync_source = $::config::puppetmaster_upstream_rsync_source
    $upstream_rsync_args   = $::config::puppetmaster_upstream_rsync_args
    $manifests_repo        = $::config::puppet_again_repo

    # puppet environments will be created for these users
    $users                 = $::config::admin_users

    if ($distinguished_master == '') {
        fail('distinguished_puppetmaster config is not specified')
    }

    # true if this is the distinguished master
    $is_distinguished = $::fqdn ? {
        $distinguished_master => true,
        default               => false
    }
}
