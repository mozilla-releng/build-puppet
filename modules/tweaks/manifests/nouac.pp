# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::nouac {
    #Disables User Access Control Challenge
    # data 1 = enable  data 0 = disabled
    registry::value { 'EnableLUA':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System',
        type => dword,
        data => '0',
    }
}
