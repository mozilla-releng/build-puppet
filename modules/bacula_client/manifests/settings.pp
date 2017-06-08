# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class bacula_client::settings {
    include ::config

    case $::operatingsystem {
        CentOS: {
            $servicename = 'bacula-fd'
            $confpath    = '/opt/bacula/etc'
            $owner       = 'root'
            $group       = 'bacula'
            $workingdir  = '/opt/bacula/working'
            $piddir      = $workingdir
        }
        Darwin: {
            $servicename = 'com.baculasystems.bacula-fd'
            $confpath    = '/Library/Preferences/bacula'
            $owner       = 'root'
            $group       = 'wheel'
            $workingdir  = '/private/var/bacula/working'
            $piddir      = '/private/var/run'
        }
        default: {
            fail("Bacula is not supported on ${::operatingsystem}")
        }
    }
}
