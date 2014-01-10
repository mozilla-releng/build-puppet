# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::global {
    include users::root
    anchor {
        'users::global::begin': ;
        'users::global::end': ;
    }

    shellprofile::file {
        "ps1":
	    content => template("${module_name}/ps1.sh.erb");
	"timeout":
	    content => "export TMOUT=86400";  # Shells timeout after 1 day
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
    
    # XXX Obsolete - No longer installed in profile.d/*
    include shellprofile::settings
    file {
        "${::shellprofile::settings::profile_d}/ps1.sh":
	    ensure => absent;
    }
}
