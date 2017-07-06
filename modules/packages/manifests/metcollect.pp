# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class packages::metcollect {
    include metcollect::settings

    case $::operatingsystem {
        Windows: {
            $exe_path = $metcollect::settings::exe_path

            file {
                $exe_path:
                    ensure => directory;

                "${exe_path}\\metcollect.exe":
                    ensure => present,
                    source => 'puppet:///repos/EXEs/metcollect.exe';
            }~>
            # Enabling diskperf raw stat is required for disk_io data
            exec { 'enabled_diskperf':
                command     => 'diskperf -Y',
                path        => "C:\\Windows\\System32",
                refreshonly => true,
            }~>
            exec { 'install_servcie':
                command     => 'metcollect.exe --startup auto install',
                path        => $exe_path,
                refreshonly => true,
            }
        }
        default: {
            fail("Metcollect cannot be installed on ${::operatingsystem}")
        }
    }
}

