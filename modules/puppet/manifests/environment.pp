# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define puppet::environment {
    include concat::setup
    include puppet::settings

    $username = $title

    file {
        "/etc/puppet/environments/${username}":
            ensure => directory,
            mode   => 0755,
            owner  => $username;

        "/etc/puppet/environments/${username}/env":
            ensure => directory,
            owner  => $username,
            group  => $username;
    }

    concat::fragment { "${username}_env" :
        target  => $puppet::settings::conf,
        content => template("puppet/puppet-env.conf.erb"),
        order   => 09,
    }
}
