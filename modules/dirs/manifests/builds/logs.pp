# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::builds::logs {
    include dirs::builds
    include users::root
    include shared

    case $::operatingsystem {
        windows: {
            file {
                'C:/builds/logs':
                    ensure => directory;
            }
        }
        default: {
            file {
                '/builds/logs' :
                    ensure => directory,
                    owner  => 'root',
                    group  => $users::root::group,
                    mode   => '0755';
            }
        }
    }
}
