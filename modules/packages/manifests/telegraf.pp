# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::telegraf {

    anchor {
        'packages::telegraf::begin': ;
        'packages::telegraf::end': ;
    }

    case $::operatingsystem {
        Ubuntu: {
            case $::operatingsystemrelease {
                16.04:  {
                    realize(Packages::Aptrepo['telegraf'])
                   Anchor['packages::telegraf::begin'] ->
                   package {
                       'telegraf':
                           ensure => 'latest';
                           #    install_options => [ '--no-install-recommends' ];
                   } -> Anchor['packages::telegraf::end']
                }
                default: {
                    fail("Ubuntu ${::operatingsystemrelease} is not supported")
                }
            }
        }
        Darwin: {
            packages::pkgdmg {
                'telegraf':
                    version             => '1.9.3',
                    os_version_specific => false,
                    private             => false;
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
