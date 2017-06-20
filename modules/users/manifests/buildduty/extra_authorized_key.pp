# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define users::buildduty::extra_authorized_key($from='', $command='') {
    include users::buildduty

    $key = $name
    ssh::extra_authorized_key {
        "buildduty-${key}":
            username => $users::buildduty::username,
            key      => $key,
            home     => $users::buildduty::home,
            from     => $from,
            command  => $command;
    }
}
