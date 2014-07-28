# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Source http://www.uvnc.com/
class packages::ultravnc{
    packages::pkgmsi {"UltraVNC":
        msi => "UltraVnc_10962_x64.msi",
        install_options => ['/QUIET'];
    }
}
