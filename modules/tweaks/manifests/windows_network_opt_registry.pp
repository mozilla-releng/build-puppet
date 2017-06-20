# This source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::windows_network_opt_registry {
    # For 2008 refrence Bugs 1165314, 1166415, & 1168812

    $serviceprovider = 'HKLM\SYSTEM\CurrentControlSet\services\Tcpip\ServiceProvider'
    $lsparameters    = 'HKLM\SYSTEM\CurrentControlSet\services\LanmanServer\Parameters'
    $afdparameters   = 'HKLM\SYSTEM\CurrentControlSet\services\AFD\Parameters'
    $tcpipparameters = 'HKLM\SYSTEM\CurrentControlSet\services\Tcpip\Parameters'
    $featuremax_0ser = 'HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPER1_0SERVER'
    $featuremax      = 'HKLM\SOFTWARE\Microsoft\Internet Explorer\MAIN\FeatureControl\FEATURE_MAXCONNECTIONSPERSERVER'
    $memmanagement   = 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management'
    $msmqparameters  = 'HKLM\SOFTWARE\Microsoft\MSMQ\Parameters'
    $dnsparameters   = 'HKLM\SYSTEM\CurrentControlSet\Services\Dnscache\Parameters'
    $pshed           = 'HKLM\SOFTWARE\Policies\Microsoft\Windows\Psched'
    $systemprofile   = 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Multimedia\SystemProfile'
    $ip6parameters   = 'HKLM\SYSTEM\CurrentControlSet\Services\Tcpip6\Parameters'

    case $::env_os_version {
        2008, w732: {
            registry::value { 'DnsPriority' :
                key  => $serviceprovider,
                type => dword,
                data => '2000',
            }
            registry::value { 'HostsPriority' :
                key  => $serviceprovider,
                type => dword,
                data => '500',
            }
            registry::value { 'LocalPriority' :
                key  => $serviceprovider,
                type => dword,
                data => '499',
            }
            registry::value { 'NetbtPriority' :
                key  => $serviceprovider,
                type => dword,
                data => '2001',
            }
            registry::value { 'Size' :
                key  =>    $lsparameters,
                type => dword,
                data => '3',
            }
            registry::value { 'AdjustedNullSessionPipes' :
                key  =>    $lsparameters,
                type => dword,
                data => '3',
            }
            registry::value { 'DefaultSendWindow' :
                key  => $afdparameters,
                type => dword,
                data => '5316608',
            }
            registry::value { 'DefaultReceiveWindow' :
                key  => $afdparameters,
                type => dword,
                data => '5316608',
            }
            registry::value { 'Tcp1323Opts' :
                key  => $tcpipparameters,
                type => dword,
                data => '3',
            }
            registry::value { 'TCPMaxDataRetransmissions' :
                key  => $tcpipparameters,
                type => dword,
                data => '5',
            }
            registry::value { 'explorer.exe' :
                key  => $featuremax_0ser,
                type => dword,
                data => '16',
            }
            registry::value { 'explorer.exe_01' :
                key   => $featuremax,
                value => 'explorer.exe',
                type  => dword,
                data  => '16',
            }
            registry::value { 'LargeSystemCache' :
                key  => $memmanagement,
                type => dword,
                data => '1',
            }
            registry::value { 'NegativeCacheTime' :
                key  => $dnsparameters,
                type => dword,
                data => 0,
            }
            registry::value { 'NetFailureCacheTime' :
                key  => $dnsparameters,
                type => dword,
                data => 0,
            }
            registry::value { 'NegativeSOACacheTime' :
                key  => $dnsparameters,
                type => dword,
                data => 0,
            }
            registry::value { 'NonBestEffortLimit' :
                key  => $pshed,
                type => dword,
                data => 0,
            }
            registry::value { 'NetworkThrottlingIndex' :
                key  =>  $systemprofile,
                type => dword,
                data => '4294967295',
            }
            registry::value { 'SystemResponsiveness' :
                key  =>  $systemprofile,
                type => dword,
                data => '10',
            }
            registry::value { 'DisabledComponents' :
                key  =>  $ip6parameters,
                type => dword,
                data => '4294967295',
            }
            case $::fqdn {
                /.*\.releng\.(use1|usw2)\.mozilla\.com$/: {
                    registry::value { 'SynAttackProtect_SEL' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '0',
                    }
                    registry::value { 'DisableTaskOffload' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '1',
                    }
                    registry::value { 'DisableTaskOffload_SEL' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '1',
                    }
                    registry::value { 'iexplorer.exe' :
                        key  => $featuremax_0ser,
                        type => dword,
                        data => '16',
                    }
                    registry::value { 'iexplorer.exe_01' :
                        key   => $featuremax,
                        value => 'iexplorer.exe',
                        type  => dword,
                        data  => '16',
                    }
                    registry::value { 'LargeSystemCache_SEL' :
                        key  =>  $msmqparameters,
                        type => dword,
                        data => '1',
                    }
                    registry::value { 'DefaultTTL' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '40',
                    }
                    registry::value { 'TcpTimedWaitDelay' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '30',
                    }
                }
                default: {
                    registry::value { 'DefaultTTL' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '64',
                    }
                    registry::value { 'DisableTaskOffload' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '0',
                    }
                    registry::value { 'EnableDca' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '1',
                    }
                    registry::value { 'EnableTCPA' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '1',
                    }
                    registry::value { 'MaxUserPort' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '65534',
                    }
                    registry::value { 'TcpTimedWaitDelay' :
                        key  => $tcpipparameters,
                        type => dword,
                        data => '30',
                    }
                    registry::value { 'LargeSystemCache_SEL' :
                        key  =>  $memmanagement,
                        type => dword,
                        data => '1',
                    }
                }
            }
        }
        default: {
            fail('Network optimization has not been configured for this platform')
        }
    }
}
