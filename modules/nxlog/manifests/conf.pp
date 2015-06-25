# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class nxlog::conf {
    include packages::nxlog
    include ::config
    include nxlog::settings

    case $::operatingsystem {
        Windows: {
            file {
                "${nxlog::settings::root_dir}/conf/nxlog.conf":
                    require => Class [ 'packages::nxlog' ],
                    content => template('nxlog/nxlog.conf.erb')
            }
        }
        default: {
            fail('Cannot configure NXLog on this platform')
        }
    }
}
