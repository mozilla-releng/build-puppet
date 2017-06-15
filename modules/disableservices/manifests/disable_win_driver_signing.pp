# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class disableservices::disable_win_driver_signing {

    registry::value { 'BehaviorOnFailedVerify':
        key  => 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Driver Signing',
        data => '0',
    }
}
