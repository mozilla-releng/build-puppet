# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Disable harddrive timeout. Refer to http://technet.microsoft.com/en-us/library/cc748940%28v=ws.10%29.aspx
class hardware::hddoff {
    shared::execonce { 'hddoff':
        command => '"C:\Windows\System32\powercfg.exe" /change disk-timeout-ac 0'
    }
}
