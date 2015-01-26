# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent::daemon {
    class { 'mig::agent::base':
        isimmortal => "on",
        installservice => "on",
        discoverpublicip => "on",
        checkin => "off",
        moduletimeout => "1200s"
    }
    # on package update, shutdown the old agent and start the new one
    # when the package is upgraded, exec a new instance of the agent
    exec {
        'restart mig':
            command => '/sbin/mig-agent -q=shutdown; /sbin/mig-agent',
            subscribe => Package['mig-agent'],
            refreshonly => true
    }
}
