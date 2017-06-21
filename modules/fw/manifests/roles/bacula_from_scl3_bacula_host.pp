# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::bacula_from_scl3_bacula_host {
    include fw::networks

    fw::rules { 'allow_infra_bacula_scl3':
        sources =>  $::fw::networks::infra_bacula_scl3,
        app     => 'bacula'
    }
}
