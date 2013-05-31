# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define ssh::userconfig($home='', $config='', $group='', $authorized_keys=[], $manage_known_hosts=true) {
    include ssh::keys
    $username = $title

    if ($home != '') {
        $home_ = $home
    } else {
        $home_ = $::operatingsystem ? {
            Darwin => "/Users/$username",
            default => "/home/$username"
        }
    }

    if ($group != '') {
        $group_ = $group
    } else {
        $group_ = $username
    }

    file {
        "$home_/.ssh":
            ensure => directory,
            mode => 0700,
            owner => $username,
            group => $group_;
        "$home_/.ssh/authorized_keys":
            mode => 0600,
            owner => $username,
            group => $group_,
            content => template("ssh/ssh_authorized_keys.erb");
    }
    if ($config != '') {
        file {
            "$home_/.ssh/config":
                mode => 0600,
                owner => $username,
                group => $group_,
                content => $config;
        }
    }

    if ($manage_known_hosts) {
        # note that this must be in the user homedir for mock builders - see bug 784177
        file {
            "$home_/.ssh/known_hosts":
                mode => 0600,
                owner => $username,
                group => $group_,
                content => template("${module_name}/known_hosts.erb");
        }
    }
}
