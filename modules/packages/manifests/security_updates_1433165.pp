# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::security_updates_1433165 {

    # This class contains pinned versions of package updates
    # See bug 1433165

    # DHCP is updated into dhcp custom repo, and defined in dhcp.pp module. So, we only need to include it
    include packages::dhcp

    anchor {
        'packages::security_updates_1433165::begin': ;
        'packages::security_updates_1433165::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['security_update_1433165'])
            Anchor['packages::security_updates_1433165::begin'] ->
            package {
                'nspr':
                    ensure => '4.13.1-1.el6';

                'libtalloc':
                    ensure => '2.1.5-1.el6_7';

                'libtdb':
                    ensure => '1.3.8-3.el6_8.2';

                'libtevent':
                    ensure => '0.9.26-2.el6_7';

                'libtirpc':
                    ensure => '0.2.1-13.el6';

                'libuser':
                    ensure => '0.56.13-8.el6_7';

                'microcode_ctl':
                    ensure => '1.17-25.el6';

                'openldap':
                    ensure => '2.4.40-16.el6';

                'pixman':
                    ensure => '0.32.8-1.el6';

                'rpcbind':
                    ensure => '0.2.0-13.el6';

            }-> Anchor['packages::security_updates_1433165::end']
        }
        Ubuntu: {
            # Do nothing yet
            # 'libxcb': is defined in packages::libxcb1
        }
        Darwin: {
            # Do nothing yet
            # 'libpng': is defined for Darwin slaves in libpng.pp
        }
        Windows: {
            # Do nothing yet
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
