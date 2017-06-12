# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define windowsutils::startup_tasks ($ensure, $command, $runas='SYSTEM') {
    if $ensure == present {
        exec { "create_${title}":
            path      => 'C:/Windows/System32/',
            command   => "schtasks.exe /CREATE /RU ${runas} /SC ONSTART /TN \"${title}\" /TR \"${command}\"",
            unless    => "schtasks.exe /QUERY /TN ${title}",
            logoutput => true,
        }
    }

    if $ensure == absent {
        exec { "delete_${title}":
            path      => 'C:/Windows/System32/',
            command   => "schtasks.exe /DELETE /F /TN \"${title}\"",
            onlyif    => "schtasks.exe /QUERY /TN \"${title}\"",
            logoutput => true,
        }
    }
}
