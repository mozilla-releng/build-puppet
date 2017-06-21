# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
define nrpe::custom($content) {
    include nrpe::base
    include nrpe::settings

    file {
        "${nrpe::settings::nrpe_etcdir}/nrpe.d/${title}":
            owner   => $::users::root::username,
            group   => $::users::root::group,
            notify  => Class['nrpe::service'],
            content => $content;
    }
}
