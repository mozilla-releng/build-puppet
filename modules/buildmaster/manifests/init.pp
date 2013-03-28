# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# buildmaster class
# include this in your node to have all the base requirements for running a
# buildbot master installed
# To setup a particular instance of a buildbot master, see
# buildmaster::buildbot_master
#
class buildmaster {
    include buildmaster::queue
    include buildmaster::settings
    include tweaks::tcp_keepalive
    service {
        "buildbot":
            require => File["/etc/init.d/buildbot"],
            enable => true;
    }
    file {
        "${buildmaster::settings::lock_dir}":
            ensure => directory,
            owner => $users::builder::group,
            group => $users::builder::username;
        "/root/.my.cnf":
            content => template("buildmaster/my.cnf.erb"),
            mode => 600;
        "/etc/init.d/buildbot":
            content => template("buildmaster/buildbot.initd.erb"),
            mode => 755;
        "/etc/default/buildbot.d/":
            ensure => directory,
            mode => 755,
            recurse => true,
            force => true;
    }
    nrpe::custom {
        "buildbot.cfg":
            content => template("buildmaster/buildbot.cfg.erb"),
    }
}
