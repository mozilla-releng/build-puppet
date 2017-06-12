# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class vnc::ultravnc_ini {
    include packages::ultravnc
    file { 'C:\Program Files\uvnc bvba\UltraVnc\ultravnc.ini':
        require   => Class['packages::ultravnc'],
        replace   => true,
        show_diff => false,
        content   => template('vnc/ultravnc.ini.erb'),
    }

    # Need to restrict access to this INI file due to a crackable hash
    # For info on icalcs command see http://technet.microsoft.com/en-us/library/cc753525.aspx
    shared::execonce {
            'restrict_vnc_ini_access' :
                command => 'C:\Windows\System32\icacls.exe "C:\Program Files\uvnc bvba\UltraVnc\ultravnc.ini" /deny cltbld:F',
                require => File['C:\Program Files\uvnc bvba\UltraVnc\ultravnc.ini'];
    }
    service {
        'uvnc_service':
            ensure    => running,
            enable    => true,
            require   => Class['packages::ultravnc'],
            subscribe => File['C:\Program Files\uvnc bvba\UltraVnc\ultravnc.ini'],
    }
}
