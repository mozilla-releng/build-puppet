# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ganglia::install {
    include packages::ganglia
    include users::root

    file {
        "/etc/ganglia":
            ensure => directory,
            owner => "root",
            group => "$::users::root::group",
            mode => 644;
    }

    service {
        gmond:
            # this file must be provided by init.pp
            require => File["/etc/ganglia/gmond.conf"],
            enable => true,
            ensure => running;
    }
}
