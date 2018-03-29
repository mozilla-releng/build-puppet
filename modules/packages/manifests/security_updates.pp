# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::security_updates {

    # This class contains pinned versions of package updates
    # See bug 1319455
    anchor {
        'packages::security_updates::begin': ;
        'packages::security_updates::end': ;
    }

    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['security_update_1319455'])
            Anchor['packages::security_updates::begin'] ->
            package {
                'cups-libs':
                    ensure => '1.4.2-74.el6';

                'expat':
                    ensure => '2.0.1-13.el6_8';

                ['file', 'file-libs']:
                    ensure => '5.04-30.el6';

                'flac':
                    ensure => '1.2.1-7.el6_6';

                'jasper-libs':
                    ensure => '1.900.1-16.el6_6.3';

                'libpng':
                    ensure => '1.2.49-2.el6_7';

                'libtiff':
                    ensure => '3.9.4-21.el6_8';

                ['krb5-devel', 'krb5-libs']:
                    ensure => '1.10.3-57.el6';

                ['libxml2', 'libxml2-python']:
                    ensure => '2.7.6-21.el6_8.1';

                ['libX11', 'libX11-common']:
                    ensure => '1.6.3-2.el6';
                'libxcb':
                    ensure => '1.11-2.el6';
                'libXcursor':
                    ensure => '1.1.14-2.1.el6';
                'libXext':
                    ensure => '1.3.3-1.el6';
                'libXfixes':
                    ensure => '5.0.1-2.1.el6';
                'libXfont':
                    ensure => '1.5.1-2.el6';
                'libXi':
                    ensure => '1.7.4-1.el6';
                'libXinerama':
                    ensure => '1.1.3-2.1.el6';
                'libXrandr':
                    ensure => '1.4.2-1.el6';
                'libXrender':
                    ensure => '0.9.8-2.1.el6';
                'libXres':
                    ensure => '1.0.7-2.1.el6';
                # 'libXtst' is set in packages::x_libs but that is not included anywhere
                'libXtst':
                    ensure => '1.2.2-2.1.el6';

                'lzo':
                    ensure => '2.03-3.1.el6_5.1';

                ['policycoreutils', 'policycoreutils-python']:
                    ensure => '2.0.83-30.1.el6_8';

                'postgresql-libs':
                    ensure => '8.4.20-6.el6';

                'rpm':
                    ensure => '4.8.0-55.el6';

                ['samba-client', 'samba-common', 'samba-winbind', 'samba-winbind-clients']:
                    ensure => '3.6.23-41.el6';

                'sqlite':
                    ensure => '3.6.20-1.el6_7.2';

            }-> Anchor['packages::security_updates::end']
            # If this is a duo enabled host, openssh is handled in  openssh.pp
            if ! $duo_enabled {
                Anchor['packages::security_updates::begin'] ->
                package {
                'openssh':
                    ensure => '5.3p1-118.1.el6_8';
                }-> Anchor['packages::security_updates::end']
            }
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
