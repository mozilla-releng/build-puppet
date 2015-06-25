# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class nxlog::settings {
    case $::operatingsystem {
        Windows: {
            $root_dir = $::hardwaremodel ? {
                x64     => 'C:/Program Files (x86)/nxlog',
                default => 'C:/Program Files/nxlog',
            }
            $conf_include = '%ROOT%\conf\nxlog_*.conf'
        }
        default: {
            fail('Cannot initialise settings for NXLog on this platform')
        }
    }
}
