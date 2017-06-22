# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class ssh::keys {
    include ::config

    $from_extsync = hiera('ssh-keys', {})

    if ($from_extsync) {
        $by_name  = merge($::config::extra_user_ssh_keys, $from_extsync)
    } else {
        $by_name  = $::config::extra_user_ssh_keys
    }
}
