# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Set up the buildduty user - this is 'buildduty' on firefox systems, but flexible
# enough to be anything

class users::syncbld {
    include config

    $username = 'syncbld'
    $group    = 'syncbld'
    $home     = "/home/${username}"

    case $::operatingsystem {
        CentOS, Ubuntu: {
            user {
                $username:
                password   => secret('buildduty_pw_hash'),
                shell      => '/bin/bash',
                managehome => true,
                comment    => 'syncbld';
            }
        }
        default: {
            fail("users::syncbld: ${::operatingsystem} not suported")
        }
    }

    file {
        "${home}/.ssh":
            ensure  => directory,
            mode    => '0700',
            owner   => $username,
            group   => $group,
            require => [
                User[$username],
            ];
        "${home}/.ssh/authorized_keys":
            mode    => '0600',
            owner   => $username,
            group   => $group,
            content => template('cruncher/syncbld_authorized_keys.erb'),
            require => [
                File["${home}/.ssh"],
            ];
    }
}
