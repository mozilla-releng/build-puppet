# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::windows_network_optimization {
    # For 2008 refrence Bugs 1165314 & 1166415 
    $ServiceProvider = 'HKLM\SYSTEM\CurrentControlSet\services\Tcpip\ServiceProvider'
    $LSParameters    = 'HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters'
    $AFDParameters   = 'HKLM\SYSTEM\CurrentControlSet\services\AFD\Parameters'
    $TCPIPParameters = 'HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters'

    case $env_os_version {
        2008: { 
            registry::value { "DnsPriority" :
                key    => $ServiceProvider,
                type   => dword,
                data   => '2000',
            }
            registry::value { "HostsPriority" :
                key    => $ServiceProvider,
                type   => dword,
                data   => '500',
            }
            registry::value { "LocalPriority" :
                key    => $ServiceProvider,
                type   => dword,
                data   => '499',
            }
            registry::value { "NetbtPriority" :
                key    => $ServiceProvider,
                type   => dword,
                data   => '2001',
            }
            registry::value { "Size" :
                key    => $LSParameters,
                type   => dword,
                data   => '3',
            }
            registry::value { "AdjustedNullSessionPipes" :
                key    => $LSParameters,
                type   => dword,
                data   => '3',
            }
            registry::value { "DefaultSendWindow" :
                key    => $AFDParameters,
                type   => dword,
                data   => '00512000',
            }
            registry::value { "DefaultReceiveWindow" :
                key    => $AFDParameters,
                type   => dword,
                data   => '00512000',
            }
            registry::value { "Tcp1323Opts" :
                key    => $TCPIPParameters,
                type   => dword,
                data   => '3',
            }
            registry::value { "DisableTaskOffload" :
                key    => $TCPIPParameters,
                type   => dword,
                data   => '0',
            }
            registry::value { "EnableDca" :
                key    => $TCPIPParameters,
                type   => dword,
                data   => '1',
            }
           registry::value { "explorer.exe" :
                key    => 'HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER',
                type   => dword,
                data   => '16',
            }
            registry::value { "explorer.exe_01" :
                key    => 'HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER',
                value  => "explorer.exe", 
                type   => dword,
                data   => '16',
            }
            registry::value { "LargeSystemCache" :
                key    => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
                type   => dword,
                data   => '1',
            }
        }
        default: {
            fail("Network optimization has not been configured for this platform")
        }
    }
}
