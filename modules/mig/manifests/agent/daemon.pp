# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent::daemon {
    class { 'mig::agent::base':
        isimmortal       => 'on',
        installservice   => 'on',
        discoverpublicip => 'on',
        discoverawsmeta  => 'on',
        checkin          => 'off',
        moduletimeout    => '1200s',
        apiurl           => 'https://api.mig.mozilla.org/api/v1/'
    }
    # on package update, shutdown the old agent and start the new one
    # when the package is upgraded, exec a new instance of the agent
    $mig_path = $::operatingsystem ? { /(CentOS|Ubuntu)/ => '/sbin/mig-agent', Darwin => '/usr/local/bin/mig-agent' }
    exec {
        'restart mig':
            command     => "${mig_path} -q=shutdown; ${mig_path}",
            subscribe   => Class['packages::mozilla::mig_agent'],
            refreshonly => true
    }
}
