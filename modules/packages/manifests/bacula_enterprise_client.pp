# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::bacula_enterprise_client {

    # Bacula Enterprise packages are non-distributable binaries
    # Please make sure they are placed in private repos

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['bacula-enterprise'])

            package {
                'bacula-enterprise-client':
                    ensure => '8.2.6-1.el6';
                'bacula-common':
                    ensure => absent;
                'bacula-client':
                    ensure => absent;
            }
        }

        Darwin: {
            packages::pkgdmg {
                'bacula-enterprise-client':
                    version             => '8.8.5-1',
                    private             => true,
                    os_version_specific => false,
                    dmgname             => 'bacula-enterprise-client-8.8.5-1.dmg';
            }
        }

        default: {
            fail("cannot install on ${::operatingsystem}")
        }
    }
}


