# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class fw::roles::nrpe_from_nagios {
    include fw::networks

    fw::rules { 'allow_nrpe_from_nagios':
        sources =>  $::fw::networks::nagios,
        app     => 'nrpe'
    }
}
