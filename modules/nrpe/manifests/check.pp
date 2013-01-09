# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# used from nrpe::check::*; do not use directly
define nrpe::check($cfg) {
    include nrpe::base

    file {
        "/etc/nagios/nrpe.d/$title.cfg":
            owner => root,
            group => root,
            notify => Class['nrpe::service'],
            content => "command[$title]=$cfg\n";
    }
}
