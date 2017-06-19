# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::config {
    include packages::httpd
    include ::config
    include users::people

    $users = $puppetmaster::settings::users

    file {
        '/etc/puppet/fileserver.conf':
            mode    => '0644',
            owner   => root,
            group   => root,
            require => Class['puppet'],
            source  => 'puppet:///modules/puppetmaster/fileserver.conf';
        '/etc/puppet/tagmail.conf':
            content => template('puppetmaster/tagmail.conf.erb');
        '/var/lib/puppet/reports':
            ensure  => directory,
            require => Class['puppet'],
            mode    => '0750',
            recurse => true,
            owner   => puppet,
            group   => puppet;
        # purge, recurse, and force are required to remove
        # user puppet environment dirs when unmangad
        '/etc/puppet/environments':
            ensure  => directory,
            purge   => true,
            recurse => false,
            force   => true,
            mode    => '0755';
    }

    # create puppet user environments for all $admin_users
    puppetmaster::environment { $users: ; }
}
