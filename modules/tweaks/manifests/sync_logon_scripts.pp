# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::sync_logon_scripts {

    # Run logon scripts synchronously
    # data 1 = enable  data 0 = disabled
    registry::value { 'RunLogonScriptSync':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
        type => dword,
        data => '1',
    }
}
