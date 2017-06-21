#This Source Code Form is subject to the terms of the Mozilla Public
#License, v. 2.0. If a copy of the MPL was not distributed with this
#file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::ms_vc100_debug {

    # Package source:
    packages::pkgmsi {
        'Microsoft_VC100_DebugCRT_x86':
            msi             => 'Microsoft_VC100_DebugCRT_x86.msi',
            private         => true,
            install_options => ['/qb'];
    }
}
