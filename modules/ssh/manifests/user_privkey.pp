# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define ssh::user_privkey($home, $username, $group, $key) {
    $key_name = $title

    file {
        "${home}/.ssh/${key_name}":
            ensure    => file,
            mode      => filemode(0600),
            owner     => $username,
            group     => $group,
            content   => $key,
            show_diff => false;
    }
}
