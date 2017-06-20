# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Disable Just In Time Debugging on Win Slaves

# env_os_version is created during the MDT install to have a variable that directly reflects the OS version

class tweaks::disablejit {
    case $::env_os_version {
        2008: {
            registry_value { 'HKLM\SOFTWARE\Microsoft\.NETFramework\DbgManagedDebugger':
                ensure => absent,
            }
            registry_value { 'HKLM\SOFTWARE\Microsoft\Windows NT\CurrentVersion\AeDebug\Debugger':
                ensure => absent,
            }
            registry_value { 'HKLM\SOFTWARE\Wow6432Node\Microsoft\Windows NT\CurrentVersion\Debugger':
                ensure => absent,
            }
            registry_value { 'HKLM\SOFTWARE\Wow6432Node\Microsoft\.NETFramework\DbgJITDebugLaunchSetting':
                ensure => absent,
            }
        }
        default: {
            fail('Not configured to disable Just-In-Time debugging for this OS version')
        }
    }
}
