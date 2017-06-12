# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define buildmaster::ssh_key {
    $key_name = $title

    ssh::user_privkey {
        $key_name:
            home     => $::users::builder::home,
            username => $::users::builder::username,
            group    => $::users::builder::group,
            key      => hiera("buildmaster_ssh_key_${key_name}");
    }
}
