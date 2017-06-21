# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::ntpdate {
    case $::operatingsystem {
        Ubuntu: {
            package {
                'ntpdate':
                    ensure => latest;
            }
        }
        Darwin, CentOS: {
            # Ignore known OSes
        }
        Windows: {
            include packages::openssl
            packages::pkgzip {
                'ntpdate-4.2.6p3-RC8-win32.zip':
                    zip        => 'ntpdate-4.2.6p3-RC8-win32.zip',
                    target_dir => '"C:\Program Files (x86)"';
            }
        }
        default: {
            fail("Cannot install on ${::operatingsystem}")
        }
    }
}
