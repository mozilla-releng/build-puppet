# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::vnc_from_rejh_logging {
    include fw::networks

    fw::rules { 'allow_vnc_from_rejh_logging':
        sources =>  $::fw::networks::rejh,
        app     => 'vnc',
        log     => true
    }
}
