# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Source http://www.uvnc.com/
class packages::ultravnc{

    $vnc_msi = $::hardwaremodel ? {
        i686    => 'UltraVnc_10962_x86.msi',
        default => 'UltraVnc_10962_x64.msi',
    }
    packages::pkgmsi {'UltraVnc':
        msi             => $vnc_msi,
        install_options => ['/QUIET'];
    }
}
