# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Set up the signer user - this is 'cltbld' on firefox systems, but flexible
# enough to be anything

class users::signer {
    include config
    anchor {
        'users::signer::begin': ;
        'users::signer::end': ;
    }

    ##
    # public variables used by other modules

    $username = $::config::signer_username

    #files are owned by staff group on macosx, rather than a group named after the user
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
        'users::signer::account':
            stage     => users,
            username  => $username,
            group     => $group,
            grouplist => [],
            home      => $home;
    }

    Anchor['users::signer::begin'] ->
    class {
        'users::signer::setup':
            username => $username,
            group    => $group,
            home     => $home;
    } -> Anchor['users::signer::end']
}
