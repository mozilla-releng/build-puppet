# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Set Power option to High Performance. Refer to http://technet.microsoft.com/en-us/library/cc748940%28v=ws.10%29.aspx
class hardware::highperformance {
    shared::execonce { 'highperformance':
        command => '"C:\Windows\System32\powercfg.exe" -setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c',
    }
}
