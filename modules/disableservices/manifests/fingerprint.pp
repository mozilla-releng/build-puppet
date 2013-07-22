# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class disableservices::fingerprint {
    # See Bug 896219 - We don't need fingerprint technology on our machines
    case $::operatingsystem {
        CentOS: {
            package {
	        "fprintd-pam":
		    ensure => absent,
		    before => Package["fprintd"];
		"fprind":
		    ensure => absent,
		    before => Package["libfprint"];
                "libfprint":
                    ensure => absent;
            }
        }
	default: {
	    # No need to act on other OS's
	}
    }
}
