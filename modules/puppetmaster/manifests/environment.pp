# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define puppetmaster::environment {
    include concat::setup

    $username = $title

    file {
        "/etc/puppet/environments/${username}":
            ensure => directory,
            mode   => '0755',
            owner  => $username,
            group  => $username;
        "/etc/puppet/environments/${username}/environment.conf":
            ensure => present,  # users can edit this without changes being overwritten
            mode   => '0644',
            owner  => $username,
            group  => $username,
            source => 'puppet:///modules/puppetmaster/user_environment.conf';
    }
}
