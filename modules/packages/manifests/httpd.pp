# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::httpd {
    case $::operatingsystem {
        CentOS: {
            realize(Packages::Yumrepo['httpd'])
            package {
                'httpd':
                    ensure => '2.2.15-56.el6.centos.3';
            }
        }
        Ubuntu: {
            package {
                'apache2':
                    ensure => latest;
            }
        }

        Darwin: {
            # installed by default
        }
        Windows: {
            # Package source: https://archive.apache.org/dist/httpd/binaries/win32/
            packages::pkgmsi {
                'Apache HTTP Server 2.2.22':
                    msi             => 'httpd-2.2.22-win32-x86-no_ssl.msi',
                    private         => true,
                    install_options => ['/qb'];
            }
        }

        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
