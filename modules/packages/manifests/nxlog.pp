# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::nxlog{
    case $::operatingsystem {
        Windows: {
            packages::pkgmsi {
                'NXLOG-CE':
                    msi             => 'nxlog-ce-2.8.1248.msi',
                    install_options => [ '/quiet' ];
            }
        }
        default: {
            fail('Cannot install NXLog on this platform')
        }
    }
}
