# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nslookup {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['security_update_1433165'])
            package {
                ['bind-utils', 'bind-libs']:  #Provided by bind-utils
                    ensure => '9.8.2-0.62.rc1.el6';
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
