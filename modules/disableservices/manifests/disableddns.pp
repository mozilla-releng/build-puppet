# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Disables Dynamic DNS updates in order to cut down on network chatter

class  disableservices::disableddns {
    registry::value { 'DisableDynamicUpdate':
        key  => 'HKLM\SOFTWARE\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters',
        type => dword,
        data => '00000001',
    }
}
