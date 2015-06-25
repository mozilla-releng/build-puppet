# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class nxlog::svc {
    include packages::nxlog
    include nxlog::settings

    case $::operatingsystem {
        Windows: {
            service {
                'nxlog':
                    ensure    => running,
                    enable    => true,
                    require   => Class [ 'packages::nxlog' ],
                    subscribe => File [ "${nxlog::settings::root_dir}/conf/nxlog.conf" ]
            }
        }
        default: {
            fail('Cannot run NXLog on this platform')
        }
    }
}
