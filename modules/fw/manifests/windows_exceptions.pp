# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::windows_exceptions {
    # Ref. https://forge.puppetlabs.com/liamjbennett/windows_firewall

    # These firewall exceptions reflect the GPO that was applied to Domain
    # managed Windows testers and builders as of July 2014.

    windows_firewall::exception { 'MozPythonIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\mozilla-build\buildbotve\scripts\python.exe',
        display_name => 'MozPythonIn',
        description  => 'Inbound rule for C:\mozilla-build\buildbotve\scripts\python.exe',
    }
    windows_firewall::exception { 'MozPythonOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\mozilla-build\buildbotve\scripts\python.exe',
        display_name => 'MozPythonOut',
        description  => 'Outbound rule for C:\mozilla-build\buildbotve\scripts\python.exe',
    }
    windows_firewall::exception { 'TalosPythonIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\talos-slave\test\build\venv\scripts\python.exe',
        display_name => 'TalosPythonIn',
        description  => 'Inbound rule for C:\talos-slave\test\build\venv\scripts\python.exe',
    }
    windows_firewall::exception { 'TalosPythonOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\talos-slave\test\build\venv\scripts\python.exe',
        display_name => 'TalosPythonOut',
        description  => 'Outbound rule for C:\talos-slave\test\build\venv\scripts\python.exe',
    }
    windows_firewall::exception { 'SlavePythonIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\venv\scripts\python.exe',
        display_name => 'SlavePythonIn',
        description  => 'Inbound rule for C:\slave\test\build\venv\scripts\python.exe',
    }
    windows_firewall::exception { 'SlavePythonOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\venv\scripts\python.exe',
        display_name => 'SlavePythonOut',
        description  => 'Outbound rule for C:\slave\test\build\venv\scripts\python.exe ',
    }
    windows_firewall::exception { 'SSHIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files\KTS\daemon.exe',
        display_name => 'SSHIn',
        description  => 'Inbound rule for C:\Program Files\KTS\daemon.exe',
    }
    windows_firewall::exception { 'SSHOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files\KTS\daemon.exe',
        display_name => 'SSHOut',
        description  => 'Outbound rule for C:\Program Files\KTS\daemon.exe',
    }
    windows_firewall::exception { 'SlaveSshTunnelIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\bin\ssltunnel.exe',
        display_name => 'SlaveSshTunnelIn',
        description  => 'Inbound rule for C:\slave\test\build\bin\ssltunnel.exe',
    }
    windows_firewall::exception { 'SlaveSshtunnelOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\bin\ssltunnel.exe',
        display_name => 'SlaveSshTunnelOut',
        description  => 'Outbound rule for C:\slave\test\build\bin\ssltunnel.exe',
    }
    windows_firewall::exception { 'SlaveTestSshTunnelIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\tests\bin\ssltunnel.exe',
        display_name => 'SlaveTestSshTunnelIn',
        description  => 'Inbound rule for C:\slave\test\build\tests\bin\ssltunnel.exe',
    }
    windows_firewall::exception { 'SlaveTestSshtunnelOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\tests\bin\ssltunnel.exe',
        display_name => 'SlaveTestSshTunnelOut',
        description  => 'Outbound rule for C:\slave\test\build\tests\bin\ssltunnel.exe',
    }
    windows_firewall::exception { 'TalosSshTunnelIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\talos-slave\test\build\bin\ssltunnel.exe',
        display_name => 'TalosSshTunelIn',
        description  => 'Inbound rule for C:\talos-slave\test\build\bin\ssltunnel.exe',
    }
    windows_firewall::exception { 'TalosSshtunnelOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\talos-slave\test\build\bin\ssltunnel.exe',
        display_name => 'TalosSshTunnelOut',
        description  => 'Oubound rule for C:\talos-slave\test\build\bin\ssltunnel.exe',
    }
    windows_firewall::exception { 'VNCIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files\uvnc bvba\ultravnc\winvnc.exe',
        display_name => 'VNCIn',
        description  => 'Inbound rule for C:\Program Files\uvnc bvba\ultravnc\winvnc.exe',
    }
    windows_firewall::exception { 'VNCOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files\uvnc bvba\ultravnc\winvnc.exe',
        display_name => 'VNCOut',
        description  => 'Outbound rule for C:\Program Files\uvnc bvba\ultravnc\winvnc.exe',
    }
    windows_firewall::exception { 'ApacheIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files (x86)\Apache Software Foundation\Apache2.2\bin\httpd.exe',
        display_name => 'ApacheIn',
        description  => 'Inbound rule for C:\Program Files (x86)\Apache Software Foundation\Apache2.2\bin\httpd.exe',
    }
    windows_firewall::exception { 'ApacheOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files (x86)\Apache Software Foundation\Apache2.2\bin\httpd.exe',
        display_name => 'ApacheOut',
        description  => 'Outbound rule for C:\Program Files (x86)\Apache Software Foundation\Apache2.2\bin\httpd.exe',
    }
    windows_firewall::exception { 'BenchMarkIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\venv\lib\site-packages\talos\startup_test\latency\win\latency-benchmark.exe',
        display_name => 'BenchMarkIn',
        description  => 'Inbound rule for C:\slave\test\build\venv\lib\site-packages\talos\startup_test\latency\win\latency-benchmark.exe',
    }
    windows_firewall::exception { 'BenchMarkOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\slave\test\build\venv\lib\site-packages\talos\startup_test\latency\win\latency-benchmark.exe',
        display_name => 'BenchMarkOut',
        description  => 'Outbound rule for C:\slave\test\build\venv\lib\site-packages\talos\startup_test\latency\win\latency-benchmark.exe',
    }
    windows_firewall::exception { 'NSClientIn':
        ensure       => present,
        direction    => 'in',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files\NSClient++\nsclient++.exe',
        display_name => 'NSClientIn',
        description  => 'Inbound rule for C:\Program Files\NSClient++\nsclient++.exe',
    }
    windows_firewall::exception { 'NSClientOut':
        ensure       => present,
        direction    => 'out',
        action       => 'Allow',
        enabled      => 'yes',
        program      => 'C:\Program Files\NSClient++\nsclient++.exe',
        display_name => 'NSClientOut',
        description  => 'Outbound rule for C:\Program Files\NSClient++\nsclient++.exe',
    }
}
