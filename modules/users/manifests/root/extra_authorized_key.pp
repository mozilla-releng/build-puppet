# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define users::root::extra_authorized_key($from='', $command='') {
    include users::root

    $key = $name
    ssh::extra_authorized_key {
        "root-${key}":
            username => $users::root::username,
            key      => $key,
            home     => $users::root::home,
            from     => $from,
            command  => $command;
    }
}

