# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define users::builder::extra_authorized_key($from='', $command='') {
    include users::builder

    $key = $name
    ssh::extra_authorized_key {
        "builder-${key}":
            username => $users::builder::username,
            key      => $key,
            home     => $users::builder::home,
            from     => $from,
            command  => $command;
    }
}
