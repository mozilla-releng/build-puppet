# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pkgbuilder {
    include config

    case $operatingsystem {
        Ubuntu: {
            # On Ubuntu, we use cowbuilder along with a custom script to build packages
            include packages::cowbuilder
            file {
                "/etc/pbuilderrc":
                    content => template("${module_name}/pbuilderrc.erb");
                "/root/pbuilderrc":
                    ensure => absent;
                "/usr/local/bin/puppetagain-build-deb":
                    source => "puppet:///modules/${module_name}/puppetagain-build-deb",
                    mode => 0755;
            }

            pkgbuilder::base_cow {
                'precise-i386': ;
                'precise-amd64': ;
            }
        }
        default: {
            fail("pkgbuilder is not spuported on $operatingsystem")
        }
    }
}

