# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class users::signer::setup($home, $username, $group) {
    anchor {
        'users::signer::setup::begin': ;
        'users::signer::setup::end': ;
    }

    ##
    # install a pip.conf for the signer user

    Anchor['users::signer::setup::begin'] ->
    python::user_pip_conf {
        $username:
            homedir => $home,
            group   => $group;
    } -> Anchor['users::signer::setup::end']

    ##
    # set up SSH configuration

    Anchor['users::signer::setup::begin'] ->
    ssh::userconfig {
        $username:
            home                          => $home,
            group                         => $group,
            authorized_keys               => [], # nobody is authorized
            authorized_keys_allows_extras => false;
    } -> Anchor['users::signer::setup::end']
}
