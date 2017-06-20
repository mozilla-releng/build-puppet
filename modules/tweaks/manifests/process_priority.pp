# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::process_priority {
    # Set the priority for foreground process.
    registry::value { 'Win32PrioritySeparation':
        key  => 'HKLM\SOFTWARE\ControlSet001\Control\PriorityControl',
        type => dword,
        data => '26',
    }
}
