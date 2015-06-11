# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::windows_network_opt_registry {
    # For 2008 refrence Bugs 1165314, 1166415, & 1168812
 
    $ServiceProvider = 'HKLM\SYSTEM\CurrentControlSet\services\Tcpip\ServiceProvider'
    $LSParameters    = 'HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters'
    $AFDParameters   = 'HKLM\SYSTEM\CurrentControlSet\services\AFD\Parameters'
    $TCPIPParameters = 'HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters'
    $FeatureMAX_0ser = 'HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER'
    $FeatureMAX      = 'HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER'
    $MemManagement   = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    $MSMQParameters  = 'HKLM\SOFTWARE\Microsoft\MSMQ\Parameters'
    $DNSParameters   = 'HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
    $Pshed           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched'  
    $SystemProfile   = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    $IP6Parameters   = 'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'

    case $env_os_version {
        2008: { 
            registry::value { "DnsPriority" :
                key  => $ServiceProvider,
                type => dword,
                data => '2000',
            }
            registry::value { "HostsPriority" :
                key  => $ServiceProvider,
                type => dword,
                data => '500',
            }
            registry::value { "LocalPriority" :
                key  => $ServiceProvider,
                type => dword,
                data => '499',
            }
            registry::value { "NetbtPriority" :
                key  => $ServiceProvider,
                type => dword,
                data => '2001',
            }
            registry::value { "Size" :
                key  => $LSParameters,
                type => dword,
                data => '3',
            }
            registry::value { "AdjustedNullSessionPipes" :
                key  => $LSParameters,
                type => dword,
                data => '3',
            }
            registry::value { "DefaultSendWindow" :
                key  => $AFDParameters,
                type => dword,
                data => '5316608',
            }
            registry::value { "DefaultReceiveWindow" :
                key  => $AFDParameters,
                type => dword,
                data => '5316608',
            }
            registry::value { "Tcp1323Opts" :
                key  => $TCPIPParameters,
                type => dword,
                data => '3',
            }
            registry::value { "TCPMaxDataRetransmissions" :
                key  => $TCPIPParameters,
                type => dword,
                data => '5',
            }
            registry::value { "DefaultTTL" :
                key  => $TCPIPParameters,
                type => dword,
                data => '64',
            }
            registry::value { "TcpTimedWaitDelay" :
                key  => $TCPIPParameters,
                type => dword,
                data => '30',
            }
           registry::value { "explorer.exe" :
                key  => $FeatureMAX_0ser,
                type => dword,
                data => '16',
            }
            registry::value { "explorer.exe_01" :
                key   => $FeatureMAX,
                value => "explorer.exe", 
                type  => dword,
                data  => '16',
            }
            registry::value { "LargeSystemCache" :
                key  => $MemManagement,
                type => dword,
                data => '1',
            }
            registry::value { "NegativeCacheTime" :
                key  => $DNSParameters,
                type => dword,
                data => 0,
            }
            registry::value { "NetFailureCacheTime" :
                key  => $DNSParameters,
                type => dword,
                data => 0,
            }
            registry::value { "NegativeSOACacheTime" :
                key  => $DNSParameters,
                type => dword,
                data => 0,
            }
            registry::value { "NonBestEffortLimit" :
                key  => $Pshed,
                type => dword,
                data => 0,
            }
            registry::value { "LargeSystemCache_SEL" :
                key  =>  $MemManagement,
                type => dword,
                data => '1',
            }
            registry::value { "NetworkThrottlingIndex" :
                key  =>  $SystemProfile,
                type => dword,
                data => '4294967295',
            }
            registry::value { "SystemResponsiveness" :
                key  =>  $SystemProfile,
                type => dword,
                data => '10',
            }
            registry::value { "DisabledComponents" :
                key  =>  $IP6Parameters,
                type => dword,
                data => '4294967295',
            }
            if ($::fqdn != "/.*\.releng\.(use1|usw2)\.mozilla\.com$/") {
                registry::value { "DisableTaskOffload" :
                    key  => $TCPIPParameters,
                    type => dword,
                    data => '0',
                }
                registry::value { "EnableDca" :
                    key  => $TCPIPParameters,
                    type => dword,
                    data => '1',
                }
                registry::value { "EnableTCPA" :
                    key  => $TCPIPParameters,
                    type => dword,
                    data => '1',
                }
                registry::value { "MaxUserPort" :
                    key  => $TCPIPParameters,
                    type => dword,
                    data => '65534',
                }
            }
            if ($::fqdn == "/.*\.releng\.(use1|usw2)\.mozilla\.com$/") {
                registry::value { "DefaultTTL" :
                    key    => $TCPIPParameters,
                    ensure => absent,
                }
                 registry::value { "MaxUserPort" :
                    key    => $TCPIPParameters,
                    ensure => absent,
                }
                 registry::value { "TcpTimedWaitDelay" :
                    key    => $TCPIPParameters,
                    ensure => absent,
                }
                 registry::value { "SynAttackProtect" :
                    key    => $TCPIPParameters,
                    ensure => absent,
                }
                 registry::value { "TCPMaxDataRetransmissions" :
                    key    => $TCPIPParameters,
                    ensure => absent,
                }
                registry::value { "SynAttackProtect_SEL" :
                    key  => $TCPIPParameters,
                    type => dword,
                    data => '0',
                }
                registry::value { "DisableTaskOffload" :
                    key  => $TCPIPParameters,
                    type => dword,
                    data => '1',
                }
                registry::value { "DisableTaskOffload_SEL" :
                    key  => $TCPIPParameters,
                    type => dword,
                    data => '1',
                }
                registry::value { "iexplorer.exe" :
                    key  => $FeatureMAX_0ser,
                    type => dword,
                    data => '16',
                }
                registry::value { "iexplorer.exe_01" :
                    key   => $FeatureMAX,
                    value => "iexplorer.exe",
                    type  => dword,
                    data  => '16',
                }
                registry::value { "LargeSystemCache_SEL" :
                    key  =>  $MSMQParameters,
                    type => dword,
                    data => '0',
                }
                 registry::value { "TCPNoDelay" :
                    key    => $MSMQParameters,
                    ensure => absent,
                }
            }
        }
        default: {
            fail("Network optimization has not been configured for this platform")
        }
    }
}

























