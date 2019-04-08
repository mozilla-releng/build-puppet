# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class users::telegraf {
    $username = 'telegraf'
    $home = $::operatingsystem ? {
        Darwin  => "/Users/${username}",
        default => "/home/${username}"
    }
    $group = $::operatingsystem ? {
        Darwin  => 'staff',
        Ubuntu  => undef,
        default => $username
    }

    user {
        'telegraf':
            # password   => '*',  # none allowed
            groups     => $group,
            comment    => 'metrics collection';
    }
}
