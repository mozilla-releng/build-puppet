# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class disableservices::disable_ms_maintenance {
    #Disable Microsoft schedule maintenance. Refer to http://technet.microsoft.com/en-us/library/cc725744.aspx for schtasks
    # Not applicable to Windows 2008 but will be needed on Windows testers
    exec { 'winSAT':
        creates => 'C:\programdata\PuppetLabs\puppet\var\lib\winSAT.txt',
        command => 'C:\Windows\System32\schtasks.exe /change /TN "\Microsoft\Windows\Maintenance\WinSAT" /DISABLE'
    }
    file {
            'C:\programdata\PuppetLabs\puppet\var\lib\winSAT.txt':
                require => Exec['winSAT'],
                content => 'Semaphore',
    }
    exec { 'Regular_Maintenance':
        creates => 'C:\programdata\PuppetLabs\puppet\var\lib\Regular_Maintence.txt',
        command => 'C:\Windows\System32\schtasks.exe /change /TN "\Microsoft\Windows\TaskScheduler\Regular Maintenance" /DISABLE'
    }
    file {
            'C:\programdata\PuppetLabs\puppet\var\lib\Regular_Maintence.txt':
                require => Exec['Regular_Maintenance'],
                content => 'Semaphore',
    }
    exec { 'Maintenance_Configurator':
        creates => 'C:\programdata\PuppetLabs\puppet\var\lib\Maintenance_Configurator.txt',
        command => 'C:\Windows\System32\schtasks.exe /change /TN "\Microsoft\Windows\TaskScheduler\Maintenance Configurator" /DISABLE'
    }
    file {
            'C:\programdata\PuppetLabs\puppet\var\lib\Maintenance_Configurator.txt':
                require => Exec['Maintenance_Configurator'],
                content => 'Semaphore',
    }
    exec { 'Idle_Maintenance':
        creates => 'C:\programdata\PuppetLabs\puppet\var\lib\Idle_Maintenance.txt',
        command => 'C:\Windows\System32\schtasks.exe /change /TN "\Microsoft\Windows\TaskScheduler\Idle Maintenance" /DISABLE'
    }
    file {
            'C:\programdata\PuppetLabs\puppet\var\lib\Idle_Maintenance.txt':
                require => Exec['Idle_Maintenance'],
                content => 'Semaphore',
    }
}
