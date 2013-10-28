# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define users::person($shell="/bin/bash") {
    $username = $title
    $home = $::operatingsystem ? {
        Darwin => "/Users/$username",
        default => "/home/$username"
    }
    $group = $::operatingsystem ? {
        Darwin => 'staff',
        default => $username
    }

    case $::operatingsystem {
        CentOS, Ubuntu: {
            user {
                $username:
                    password => '*', # invalid password, but not locked
                    shell => $shell,
                    home => $home,
                    comment => "Created by Puppet";
            }
        }
        Darwin: {
            darwinuser {
                $username:
                    gid => $group,
                    shell => $shell,
                    home => $home,
                    comment => "Created by Puppet";
            }
        }
    }

    # setup homedir
    file {
        $home:
            source => [
                "puppet:///modules/users/people/$username",
                "puppet:///modules/users/people/skel"
            ],
            # note: purge is not enabled, and recurse => remote only
            # recurses on the master, so this doesn't make puppet look
            # at any large or numerous files on-disk.
            recurse => remote,
            # remove things ssh won't like, but otherwise take the perms from
            # the files as they are.
            mode => 'g-w,o-rwx',
            owner => $username,
            group => $group,
            require => $::operatingsystem ? {
                Darwin => [ Darwinuser[$username] ],
                default => []
            };
    }

    # set up SSH
    ssh::userconfig {
        $username:
            home => $home,
            group => $group,
            manage_known_hosts => false,
            authorized_keys => [ $username ];
    }
}
