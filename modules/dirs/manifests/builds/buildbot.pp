# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::builds::buildbot {
    include users::builder
    include config
    include dirs::builds

        case $::operatingsystem {
            windows: {
                file {
                    'C:/builds/buildbot':
                        ensure => directory;
                }
            }
        default: {
            file {
                '/builds/buildbot' :
                    ensure => directory,
                    owner  => $users::builder::username,
                    group  => $users::builder::group,
                    mode   => '0755';
            }
        }
    }
}
