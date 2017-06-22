# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class rdp::enable_rdp {
    #Enables Remote desktop access
    registry::value { 'fDenyTSConnections':
        key  => 'HKLM\system\currentcontrolset\control\Terminal Server',
        type => dword,
        data => '0';
    }
    registry::value { 'UserAuthentication':
        key  => 'HKLM\system\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp',
        type => dword,
        data => '0';
    }
    # The service resource will throw errors when attempting to restart the services below hence falling back to the exec resource 
    # Ref: https://bugzilla.mozilla.org/show_bug.cgi?id=1149726
    exec {
        'SessionEnv' :
        command     => 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe restart-service -name SessionEnv" -force',
        subscribe   => [Registry::Value['fDenyTSConnections'],
                        Registry::Value['UserAuthentication']
                        ],
        refreshonly => true;
    }
    # Restarting Termservice will also restart the UmRdpService service
    exec {
        'TermService' :
        command     => 'C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe restart-service -name termservice -force"',
        subscribe   => [Registry::Value['fDenyTSConnections'],
                        Registry::Value['UserAuthentication']
                        ],
        refreshonly => true;
    }
}
