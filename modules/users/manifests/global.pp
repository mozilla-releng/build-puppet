# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::global {
    include users::root
    shellprofile::file {
        "ps1":
	    content => template("${module_name}/ps1.sh.erb");
	"timeout":
	    content => "export TMOUT=86400";  # Shells timeout after 1 day
    }

    # On OS X, the Administrator user is created at system install time.  We
    # don't want to keep it around, except on Mavericks (10.9, and by the look
    # of the error messages future versions too), where it seems critical to
    # proper system operation.
    if ($::operatingsystem == "Darwin") {
        case $macosx_productversion_major {
            10.6,10.7,10.8: {
                darwinuser {
                    "administrator":
                        ensure => absent;
                }
            }
            default: {
                darwinuser {
                    "administrator":
                        ensure => present,
                        password => secret("root_pw_pbkdf2"),
                        salt => secret("root_pw_pbkdf2_salt"),
                        iterations => secret("root_pw_pbkdf2_iterations");
                }
            }
        }
    }

    # XXX Obsolete - No longer installed in profile.d/*
    include shellprofile::settings
    file {
        "${::shellprofile::settings::profile_d}/ps1.sh":
	    ensure => absent;
    }
}
