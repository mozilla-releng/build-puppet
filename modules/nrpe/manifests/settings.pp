# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class nrpe::settings {
    include ::shared

    case $::operatingsystem {
        Darwin: {
            $plugins_dir = '/usr/local/libexec'
        }
        Ubuntu: {
            $plugins_dir = '/usr/lib/nagios/plugins'
        }
        default: {
            $plugins_dir = "/usr/${::shared::lib_arch_dir}/nagios/plugins"
        }
    }
    $nrpe_etcdir = '/etc/nagios/'
}
