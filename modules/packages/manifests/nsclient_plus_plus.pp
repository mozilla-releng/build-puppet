# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class packages::nsclient_plus_plus{
    # source http://nsclient.org/nscp/downloads
    packages::pkgmsi { 'NSClient++ (x64)':
        msi             => 'NSClient++-0.3.9-x64.msi',
        install_options => ['/QUIET'];
    }
}
