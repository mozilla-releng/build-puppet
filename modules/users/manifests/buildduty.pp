# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Set up the buildduty user - this is 'buildduty' on firefox systems, but flexible
# enough to be anything

class users::buildduty {
    include config
    anchor {
        'users::buildduty::begin': ;
        'users::buildduty::end': ;
    }
    # public variables used by other modules

    $username = $::config::buildduty_username
    $group = $username
    $home = "/home/${username}"

    # account happens in the users stage, and is not included in the anchor
    class {
        'users::buildduty::account':
            stage    => users,
            username => $username,
            group    => $group,
            home     => $home;
    }

    Anchor['users::buildduty::begin'] ->
    class {
        'users::buildduty::setup':
            username => $username,
            group    => $group,
            home     => $home;
    } -> Anchor['users::buildduty::end']
}
