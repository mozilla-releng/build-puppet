# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Set memory paging parameters

class tweaks::memory_paging {

    registry::value { 'BootId':
        key  => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters',
        data => '00000012',
    }
    registry::value { 'BaseTime':
        key  => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management\PrefetchParameters',
        data => '185729f9',
    }
    shared::execonce {'mempage' :
        command => 'C:\Windows\System32\reg.exe add "HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management" /v "PagingFiles" /t REG_MULTI_SZ /d "c:\pagefile.sys 4048 4048" /f',
    }
    case $::env_os_version {
        2008: {
            registry::value { 'DisablePagingExecutive':
                key  => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
                data => '0',
            }
        }
        default: {
            registry::value { 'DisablePagingExecutive':
                key  => 'HKLM\SYSTEM\CurrentControlSet\Control\Session Manager\Memory Management',
                data => '1',
            }
        }
    }
}
