# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define slave_secrets::ssh_key($slave_keyset) {
    $key_name    = $title
    $secret_name = $slave_keyset[$key_name]

    ssh::user_privkey {
        $key_name:
            home     => $::users::builder::home,
            username => $::users::builder::username,
            group    => $::users::builder::group,
            key      => hiera($secret_name);
    }
}
