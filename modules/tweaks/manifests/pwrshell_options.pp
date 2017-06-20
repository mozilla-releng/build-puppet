# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::pwrshell_options {
    #Set powershell option to allow all poershell scripts to be ran. Refer to http://technet.microsoft.com/en-us/library/ee176961.aspx.
    shared::execonce { 'pwrshellopt':
        command => '"C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -noprofile Set-ExecutionPolicy Unrestricted',
    }
}
