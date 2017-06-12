# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster::base class
# include this in your node to have all the base requirements for running a
# buildbot master installed
# To setup a particular instance of a buildbot master,
# see the buildmaster::buildbot_master types
#

class buildmaster::base {
    include config
    include users::builder
    include nrpe::check::mysql

    include buildmaster::settings
    include tweaks::tcp_keepalive
    service {
        'buildbot':
            require => File['/etc/init.d/buildbot'],
            enable  => true;
    }
    file {
        $buildmaster::settings::lock_dir:
            ensure => directory,
            owner  => $users::builder::group,
            group  => $users::builder::username;
        '/root/.my.cnf':
            content   => template('buildmaster/my.cnf.erb'),
            mode      => '0600',
            show_diff => false;
        '/etc/init.d/buildbot':
            content => template('buildmaster/buildbot.initd.erb'),
            mode    => '0755';
        '/etc/default/buildbot.d/':
            ensure  => directory,
            mode    => '0755',
            recurse => true,
            force   => true;
    }
    nrpe::custom {
        'buildbot.cfg':
            content => template('buildmaster/buildbot.cfg.erb'),
    }

    buildmaster::ssh_key {
        $::config::buildmaster_ssh_keys: ;
    }
}
