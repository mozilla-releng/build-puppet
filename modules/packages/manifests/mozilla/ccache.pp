# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::mozilla::ccache {
    case $::operatingsystem {
        CentOS: {
            package {
                'ccache':
                    ensure => '3.1.9-3moz0';
            }
        }
        Darwin: {
            packages::pkgdmg {
                'ccache':
                    version => '3.1.7';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
