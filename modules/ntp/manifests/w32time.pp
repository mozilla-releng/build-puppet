# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ntp::w32time ($daemon = true) {
    include registry
    include ::config
    include packages::ntpdate
    include stdlib

    # Determine if w32time should run continuously
    if $daemon {
        $type           = 'NTP'
        $service_ensure = 'running'
    } else {
        $type           = 'NoSync'
        $service_ensure = 'stopped'
    }

    $ntp_servers        = $config::ntp_servers

    # NtpServer registy data must be formatted to indicate client mode
    # see https://technet.microsoft.com/en-us/library/Cc773263%28v=WS.10%29.aspx
    $fmt_servers_str    = join(suffix($ntp_servers, ',0x8'), ' ')

    # Select a single server for ntpdate
    $sntp_server        = $ntp_servers[0]

    # Disable the default windows time sync task
    windowsutils::startup_tasks { '\Microsoft\Windows\Time Synchronization\SynchronizeTime':
        ensure  => absent,
        command => '',
    }

    # Set ntpdate to run on startup
    windowsutils::startup_tasks { 'ntpdate':
        ensure  => present,
        command => "C:\\Program Files (x86)\\ntpdate\\ntpdate.exe ${sntp_server}",
        require => Class['packages::ntpdate'];
    }

    # w32time service parameters
    registry_value { 'HKLM\System\CurrentControlSet\Services\W32Time\Parameters\Type':
        ensure => present,
        type   => string,
        data   => $type,
        notify => Service['W32Time'],
    }
    registry_value { 'HKLM\System\CurrentControlSet\Services\W32Time\Parameters\NtpServer':
        ensure => present,
        type   => string,
        data   => $fmt_servers_str,
        notify => Service['W32Time'],
    }
    service { 'W32Time':
        ensure => $service_ensure,
        enable => $daemon,
    }
}
