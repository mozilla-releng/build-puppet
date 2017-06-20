# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class users::deploystudio {
    include config
    anchor {
        'users::deploystudio::begin': ;
        'users::deploystudio::end': ;
    }

    ##
    # public variables used by other modules

    $username = $::config::deploystudio_username
    if ! $username or $username == '' {
        fail('Deploystudio username is not defined or empty')
    }

    # uid must be specified >500 for the user to be visable in the fileshare gui
    # https://tickets.puppetlabs.com/browse/PUP-3833
    $uid = $config::deploystudio_uid
    if $uid < 500 {
        fail('Deploystudio user UID must be set above 500')
    }

    #files are owned by staff group on macosx
    $group =  'staff'

    # calculate the proper homedir
    $home =  "/Users/${username}"

    # account happens in the users stage, and is not included in the anchor
    class {
        'users::deploystudio::account':
            stage     => users,
            username  => $username,
            group     => $group,
            grouplist => [],
            home      => $home,
            uid       => $uid;
    }

    Anchor['users::deploystudio::begin'] ->
    class {
        'users::deploystudio::setup':
            username => $username,
            group    => $group,
            home     => $home;
    } -> Anchor['users::deploystudio::end']
}
