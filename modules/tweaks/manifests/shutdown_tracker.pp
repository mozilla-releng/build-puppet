# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::shutdown_tracker {
    #Disables Shutdown Tracker
    registry::value { 'ShutdownReasonOn':
        key  => 'HKLM\SOFTWARE\Policies\Microsoft\Windows NT\Reliability',
        data => '0',
    }
}
