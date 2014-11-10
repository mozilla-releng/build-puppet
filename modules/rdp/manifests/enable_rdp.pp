# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class rdp::enable_rdp {
    #Enables Remote desktop access
    $service_notifies = [     
        Service["Remote Desktop Service"],
        Service["Remote Desktop Configuration"],
        Service["Remote Desktop Services UserMode Port Redirector"]
    ]
    registry::value { 'fDenyTSConnections':
        key    => 'HKLM\system\currentcontrolset\control\Terminal Server',
        type   => dword,
        data   => '0',
        notify => $service_notifies;
    }
    registry::value { 'UserAuthentication':
        key    => 'HKLM\system\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp',
        type   => dword,
        data   => '0',
        notify => $service_notifies;
    }
    service {"Remote Desktop Service":
        restart => true,
    }
    service {"Remote Desktop Configuration":
        restart => true,
    }
    service {"Remote Desktop Services UserMode Port Redirector":
        restart => true,
    } 
}
