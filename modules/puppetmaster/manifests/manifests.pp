# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::manifests {
    include ::config
    include packages::mercurial
    include puppetmaster::settings

    $puppetsync_home      = $puppetmaster::settings::puppetsync_home
    $distinguished_master = $puppetmaster::settings::distinguished_master

    # check out the manifests to begin with
    $checkout_dir = '/etc/puppet/production'
    exec {
        'checkout-puppet':
            command   => "/usr/bin/git clone ${puppetmaster::settings::manifests_repo} ${checkout_dir}",
            creates   => $checkout_dir,
            logoutput => on_failure,
            require   => Class['packages::mercurial'];
    }

    # and create environment.conf, containing a long(ish) environment timeout
    file {
        "${checkout_dir}/environment.conf":
            source  => 'puppet:///modules/puppetmaster/environment.conf',
            require => Exec['checkout-puppet'];
    }

    # update the manifests regularly
    file {
        '/etc/puppet/update.sh':
            mode    => '0755',
            owner   => root,
            group   => root,
            content => template('puppetmaster/update.sh.erb');
        '/etc/puppet/get_rev.sh':
            mode    => '0755',
            owner   => root,
            group   => root,
            content => template('puppetmaster/get_rev.sh.erb');
        '/etc/cron.d/puppetmaster-update.cron':
            content => template('puppetmaster/puppetmaster-update.cron.erb');
    }

    # make sure that nodes.pp and config.pp exist
    exec {
        'check-for-nodes.pp':
            command   => "/bin/echo 'Please set up ${checkout_dir}/manifests/nodes.pp appropriately'; false",
            logoutput => true,
            creates   => "${checkout_dir}/manifests/nodes.pp",
            require   => Exec['checkout-puppet'];
        'check-for-config.pp':
            command   => "/bin/echo 'Please set up ${checkout_dir}/manifests/config.pp appropriately'; false",
            logoutput => true,
            creates   => "${checkout_dir}/manifests/config.pp",
            require   => Exec['checkout-puppet'];
    }
}
