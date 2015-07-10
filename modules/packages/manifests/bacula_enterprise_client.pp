# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::bacula_enterprise_client {
    case $::operatingsystem {
        CentOS: {
            # note that this repo is private
            realize(Packages::Yumrepo['bacula-enterprise'])

            package {
                'bacula-enterprise-client':
                    ensure => present;
                'bacula-common':
                    ensure => absent;
                'bacula-client':
                    ensure => absent;
            }
        }

        default: {
            fail("cannot install on $::operatingsystem")
        }
    }
}


