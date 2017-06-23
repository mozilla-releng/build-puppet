# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define ssh::userconfig($home='', $config='', $group='', $cleartext_password='',
            $authorized_keys=[], $authorized_keys_allows_extras=false,
            $manage_known_hosts=true) {
    include concat::setup
    include ssh::settings
    include ssh::keys
    $username = $title

    if ($home != '') {
        $home_ = $home
    } else {
        $home_ = $::operatingsystem ? {
            Darwin  => "/Users/${username}",
            Windows => "C:/users/${username}",
            default => "/home/${username}"
        }
    }

    case $::operatingsystem {
        windows: {
            # setting owner or group causes ACLs to be blown away, so don't
            $owner_ = undef
            $group_ = undef
        }
        default: {
            $owner_ = $username
            if ($group != '') {
                $group_ = $group
            } else {
                $group_ = $username
            }
        }
    }

    file {
        "${home_}/.ssh":
            ensure  => directory,
            mode    => filemode(0700),
            owner   => $owner_,
            group   => $group_,
            purge   => true,
            recurse => true,
            force   => true,
            backup  => false;
    }

    $authorized_keys_file = $::operatingsystem ? {
        windows => "${ssh::settings::genkey_dir}/${username}.keys",
        default => "${home_}/.ssh/authorized_keys",
    }

    if ($authorized_keys_allows_extras) {
        # to allow extras, set this up with concat
        concat {
            $authorized_keys_file:
                owner  => $owner_,
                group  => $group_,
                mode   => filemode(0600),
                notify => $ssh::settings::notify_on_key_change;
        }
        concat::fragment {
            "${home_}::${::base}":
                target  => $authorized_keys_file,
                content => template('ssh/ssh_authorized_keys.erb');
        }

    } else {
        # if no extras are allowed (the common case), just use a file
        file {
            $authorized_keys_file:
                owner   => $owner_,
                group   => $group_,
                mode    => filemode(0600),
                content => template('ssh/ssh_authorized_keys.erb'),
                notify  => $ssh::settings::notify_on_key_change;
        }
    }

    if ($config != '') {
        file {
            "${home_}/.ssh/config":
                owner   => $owner_,
                group   => $group_,
                mode    => filemode(0600),
                content => $config;
        }
    } else {
        # allow the config to remain in place
        file {
            "${home_}/.ssh/config":
                ensure => present,
                owner  => $owner_,
                group  => $group_,
                mode   => filemode(0600);
        }
    }

    if ($manage_known_hosts) {
        # note that this must be in the user homedir for mock builders - see bug 784177
        file {
            "${home_}/.ssh/known_hosts":
                owner   => $owner_,
                group   => $group_,
                mode    => filemode(0600),
                content => template("${module_name}/known_hosts.erb");
        }
    }

    # on windows, we need the password for the publickey_logon.ini file, so write
    # that to the genkeys directory
    if ($::operatingsystem == 'Windows' and $cleartext_password != '') {
        file {
            "${ssh::settings::genkey_dir}/${username}.pass":
                content => $cleartext_password,
                notify  => $ssh::settings::notify_on_key_change;
        }
    }
}
