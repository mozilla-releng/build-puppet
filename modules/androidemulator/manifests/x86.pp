# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class androidemulator::x86 {
    include users::builder

    case $::operatingsystem {
        Ubuntu: {
	    # We want it on Ubuntu
	    file {
	        "${::users::builder::home}/avds":
                    ensure => directory,
                    owner => "$users::builder::username",
                    group => "$users::builder::group",
                    mode => 0755;
	        "${::users::builder::home}/avds/test-x86.tar.gz":
		    source => "puppet:///repos/private/avds/test-x86-aug6.tar.gz",
		    owner  => $users::builder::username,
		    group  => $users::builder::group;
	    }
	}
    }
}
