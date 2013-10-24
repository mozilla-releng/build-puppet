# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class pkgbuilder {
    case $operatingsystem {
        Ubuntu: {
            # On Ubuntu, we use cowbuilder along with a custom script to build packages
            include packages::cowbuilder
            file {
                "/etc/pbuilderrc":
                    source => "puppet:///modules/${module_name}/pbuilderrc";
                "/root/pbuilderrc":
                    ensure => absent;
                "/usr/local/bin/puppetagain-build-deb":
                    source => "puppet:///modules/${module_name}/puppetagain-build-deb",
                    mode => 0755;
            }

            exec {
                'setup-cowbuilder':
                    command => "/usr/sbin/cowbuilder --create",
                    creates => "/var/cache/pbuilder/base.cow",
                    logoutput => true,
                    require => Class['packages::cowbuilder'];
                'update-cowbuilder':
                    command => "/usr/sbin/cowbuilder --update",
                    refreshonly => true,
                    logoutput => true,
                    subscribe => File['/etc/pbuilderrc'],
                    require => Class['packages::cowbuilder'];
            }
        }
        default: {
            fail("pkgbuilder is not spuported on $operatingsystem")
        }
    }
}

