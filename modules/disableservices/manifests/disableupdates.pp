# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

#Disables Automatic Windows Updates
#Approved Updates are downloaded and applied during the MDT installation

class disableservices::disableupdates {
    registry::value { 'NoActiveDesktop':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        type => dword,
        data => '00000001',
    }
    registry::value { 'NoActiveDesktopChanges':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        type => dword,
        data => '00000001',
    }
    registry::value { 'ForceActiveDesktopOn':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        type => dword,
        data => '00000000',
    }
    registry::value { 'ShowSuperHidden':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        type => dword,
        data => '00000001',
    }
    registry::value { 'NoWindowsUpdate':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer',
        type => dword,
        data => '00000001',
    }
}
