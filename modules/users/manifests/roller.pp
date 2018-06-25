# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class users::roller {
    include config
    anchor {
        'users::roller::begin': ;
        'users::roller::end': ;
    }
    # public variables used by other modules

    $username = $::config::roller_username

    $group = $::operatingsystem ? {
        Darwin => 'staff',
        default => $username
    }

    # calculate the proper homedir
    $home = $::operatingsystem ? {
        Darwin  => "/Users/${username}",
        default => "/home/${username}"
    }

    # account happens in the users stage, and is not included in the anchor
    class {
        'users::roller::account':
            stage     => users,
            username  => $username,
            group     => $group,
            grouplist => [],
            home      => $home;
    }

    Anchor['users::roller::begin'] ->
    class {
        'users::roller::setup':
            username => $username,
            group    => $group,
            home     => $home;
    } -> Anchor['users::roller::end']
}
