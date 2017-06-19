# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class metcollect {
    include metcollect::settings

    # do not include unless graphite server is defined
    if $metcollect::settings::metcollect_enabled == true {

        include packages::metcollect

        $exe_path = $metcollect::settings::exe_path
        $nodes = $metcollect::settings::write['graphite_nodes']

        file { "${exe_path}\\metcollect.ini":
            ensure  => present,
            content => template('metcollect/metcollect.ini.erb'),
            notify  => Service['metcollect'],
            require => Class['packages::metcollect'];
        }

        service { 'metcollect':
            ensure  => running,
            enable  => true,
            require => Class['packages::metcollect'];
        }
    }
}

