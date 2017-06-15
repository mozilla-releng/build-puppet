# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Disables Automatic Windows Defender to conserve resources
# Note this will throw a permissions based error when the Puppet catalog is being applied outside of the context of highest privileges
# It can be ignored during testing

class disableservices::disable_win_defend {
    registry::value { 'DisableRemovableDriveScanning':
        key  => 'HKLM\SOFTWARE\Microsoft\Windows Defender\Scan',
        data => '1',
    }
}
