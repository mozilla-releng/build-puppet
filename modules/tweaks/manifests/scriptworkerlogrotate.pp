# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class tweaks::scriptworkerlogrotate {
    case $::operatingsystem {
        CentOS: {
            # Bug 1389512 beetmover/scriptworker machines are not zipping logs when they rotate them
            file { '/etc/logrotate.d/scriptworker':
              source  => 'puppet:///modules/tweaks/scriptworker.logrotate',
              ensure => present;
            }
        }
        default: {
            notice("Don't know how to tweak scriptworker logrotate on ${::operatingsystem}.")
        }
    }
}
