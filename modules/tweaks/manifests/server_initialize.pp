# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Disable Server Initialization logon window
class tweaks::server_initialize {
    # data 1 = enable  data 0 = disabled
    registry::value { 'DoNotOpenInitialConfigurationTasksAtLogon':
        key  => 'HKLM\SOFTWARE\Microsoft\ServerManager\Oobe',
        type => dword,
        data => '1',
    }
}
