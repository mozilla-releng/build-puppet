# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class casper::settings {

    $fs_accounts = {
        'casper_rw' => { uid => 1001, },
        'casper_ro' => { uid => 1002, },
    }

}
