# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class puppetmaster::dirs {
    include puppetmaster::settings
    include puppetmaster::install

    file {
        $puppetmaster::settings::data_root:
            ensure => directory,
            owner  => puppetsync,
            group  => puppetsync;
        $puppetmaster::settings::puppetmaster_root:
            ensure  => directory,
            owner   => puppet,
            group   => puppet,
            require => Class['puppetmaster::install'];
    }
}
