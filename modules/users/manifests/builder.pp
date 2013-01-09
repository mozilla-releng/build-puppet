# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Set up the builder user - this is 'cltbld' on firefox systems, but flexible
# enough to be anything

class users::builder {
    include config
    anchor {
        'users::builder::begin': ;
        'users::builder::end': ;
    }

    ##
    # public variables used by other modules

    $username = $::config::builder_username

    #files are owned by staff group on macosx, rather than a group named after the user
    $group = $::operatingsystem ? {
        Darwin => 'staff',
        default => $username
    }

    # calculate the proper homedir
    $home = $::operatingsystem ? {
        Darwin => "/Users/$username",
        default => "/home/$username"
    }

    # account happens in the users stage, and is not included in the anchor
    class {
        'users::builder::account':
            stage => users,
            username => $username,
            group => $group,
            home => $home;
    }

    Anchor['users::builder::begin'] ->
    class {
        'users::builder::setup':
            username => $username,
            group => $group,
            home => $home;
    } -> Anchor['users::builder::end']
}
