# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::base {
    include nrpe::settings
    include nrpe::install
    include nrpe::service
    include config # for vars for templates

    $plugins_dir = $nrpe::settings::plugins_dir
    $nrpe_etcdir = $nrpe::settings::nrpe_etcdir

    # configure
    file {
        "${nrpe_etcdir}/nrpe.cfg":
            content => template("nrpe/nrpe.cfg.erb"),
            owner   => "root",
            group   => "root",
            require => Package["nrpe"],
            notify => Class['nrpe::service'];
        "${nrpe_etcdir}/nrpe.d":
            ensure => directory,
            owner  => "root",
            group  => "root",
            recurse => true,
            purge => true,
            require => Package["nrpe"],
            notify => Class['nrpe::service'];
    }
}
