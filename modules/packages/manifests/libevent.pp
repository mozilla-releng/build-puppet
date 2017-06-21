# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::libevent {
    case $::operatingsystem {
        CentOS: {
            package {
                ['libevent', 'libevent-devel']:
                    ensure => latest;
            }
        }

        Darwin: {
            packages::pkgdmg {
                'libevent':
                    version => '2.0.21-stable';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
