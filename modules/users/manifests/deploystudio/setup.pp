# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::deploystudio::setup($home, $username, $group) {
    anchor {
        'users::deploystudio::setup::begin': ;
        'users::deploystudio::setup::end': ;
    }

    ##
    # set up SSH configuration

    Anchor['users::deploystudio::setup::begin'] ->
    ssh::userconfig {
        $username:
            home                          => $home,
            group                         => $group,
            authorized_keys               => [], # deploystudio uses password only
            authorized_keys_allows_extras => false;
    } -> Anchor['users::deploystudio::setup::end']

}
