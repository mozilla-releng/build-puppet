# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class dirs::usr::local::bin {
    include dirs::usr::local
    include users::root

    file {
        '/usr/local/bin':
            ensure => directory,
            owner  => 'root',
            group  => $users::root::group,
            mode   => '0755';
    }
}
