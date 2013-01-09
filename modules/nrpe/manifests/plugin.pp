# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# used from nrpe::check::*; do not use directly
define nrpe::plugin {
    include nrpe::base
    include nrpe::settings

    file {
        "$nrpe::settings::plugins_dir/$title":
            owner => root,
            group => root,
            mode => 0755,
            require => Class['nrpe::install'],
            source => "puppet:///modules/nrpe/$title";
    }
}
