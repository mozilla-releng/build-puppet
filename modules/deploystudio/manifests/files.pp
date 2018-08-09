# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class deploystudio::files {
    include deploystudio::settings

    $deploy_dir = $::deploystudio::settings::deploy_dir

    # Make sure deploypass is set in hiera
    if secret('deploy_password') == '' {
        fail('missing deploy_password')
    }
    $deploy_password = secret('deploy_password')

    file {
        $deploy_dir:
            ensure => directory;
        "${deploy_dir}/Files":
            ensure => directory;
        "${deploy_dir}/Files/puppetize.sh":
            ensure => present,
            source => 'puppet:///modules/puppet/puppetize.sh';
        "${deploy_dir}/Files/org.mozilla.puppetize.plist":
            ensure => present,
            source => 'puppet:///modules/puppet/org.mozilla.puppetize.plist';
        "${deploy_dir}/Files/deploypass":
            ensure    => present,
            show_diff => false,
            content   => "${deploy_password}\n";
    }

    # RPC ports are set static to accommodate firewall(s)
    file { '/etc/nfs.con':
        ensure => present,
        source => 'puppet:///modules/deploystudio/nfs.conf';
    }
}

