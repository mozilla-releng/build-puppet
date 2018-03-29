# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::sudo {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['security_update_1433165'])
            package {
                'sudo':
                    ensure => '1.8.6p3-27.el6';
            }
        }
        Ubuntu : {
            package {
                'sudo' :
                    ensure => latest ;
            }
        }
        Darwin : {
        # installed by default

        }
        default : {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
