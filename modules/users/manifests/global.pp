# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::global {
    include users::root
    anchor {
        'users::global::begin': ;
        'users::global::end': ;
    }

    # set the bash prompt
    $profile_d = $::operatingsystem ? {
        Windows => 'c:/windows/profile.d',
        default => '/etc/profile.d',
    }
    file {
        "${profile_d}":
            ensure => directory,
            owner => $users::root::username,
            group => $users::root::group;
        "${profile_d}/ps1.sh":
            content => template("${module_name}/ps1.sh.erb"),
            owner => $users::root::username,
            group => $users::root::group;
    }
    case ($::operatingsystem) {
        CentOS: {
            # profile.d actually works out of the box
        }
        Ubuntu: {
            # ~root/.bashrc is patched in users::root::setup
        }
        Darwin: {
            file {
                # patch /etc/profile to run /etc/profile.d/*.sh
                "/etc/profile":
                    source => "puppet:///modules/users/darwin-profile";
            }
        }
        Windows: {
            # TODO: add support to set PS1 on Windows
        }
        default: {
            fail("don't know how to set PS1 on this operating system")
        }
    }

    # put some basic information in /etc/motd
    Anchor['users::global::begin'] ->
    motd {
        "hostid":
            content => inline_template("This is <%= @fqdn %> (<%= @ipaddress %>)\n"),
            order => '00';
    } -> Anchor['users::global::end']

    # On OS X, the Administrator user is created at system install time.  We
    # don't want to keep it around.
    if ($::operatingsystem == "Darwin") {
        darwinuser {
            "administrator":
                ensure => absent;
        }
    }
}
