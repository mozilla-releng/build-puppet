# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent::checkin {
    # when running in checkin mode, each invocation of mig-agent performs
    # one check-in, runs all pending actions, and exits
    class { 'mig::agent::base':
        isimmortal       => 'off',
        installservice   => 'off',
        discoverpublicip => 'on',
        discoverawsmeta  => 'off',
        checkin          => 'on',
        moduletimeout    => '300s',
        apiurl           => 'https://api.mig.mozilla.org/api/v1/'
    }
    # ensure some of the service files aren't present
    file {
        [ '/etc/cron.d/mig-agent', '/etc/init/mig-agent.conf',
          '/etc/init.d/mig-agent', '/etc/systemd/system/mig-agent.service']:
            ensure => absent
    }
    include runner::tasks::mig_agent
}
