# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::builds::slave {
    include dirs::builds

    case $::operatingsystem {
        windows: {
            file {
                # XXX on windows it's named differently :(
                # Best fix: switch to c:/builds/slave on windows
                # Other fix: create dirs::builds::moz2_slave and use that in puppet
                'C:/builds/moz2_slave':
                    ensure => directory;
            }
        }
        default: {
            include users::builder
            file {
                '/builds/slave' :
                    ensure => directory,
                    owner  => $users::builder::username,
                    group  => $users::builder::group,
                    mode   => '0755';
            }
        }
    }
}
