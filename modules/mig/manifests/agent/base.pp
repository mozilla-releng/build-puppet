# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent::base(
    $isimmortal,
    $installservice,
    $discoverpublicip,
    $discoverawsmeta,
    $checkin,
    $moduletimeout,
    $apiurl
) {
    include packages::mozilla::mig_agent
    case $::operatingsystem {
        'CentOS', 'RedHat', 'Ubuntu', 'Darwin': {
            # Package installation is performed in packages::mozilla::mig_agent
            # Service startup is done in mig::agent::daemon. The service is not started in checkin mode,
            # because runner::tasks::mig_agent will invoke it between build jobs.
            #
            # The files below are used to provision secrets for the agent. More details can be found
            # in the doc at https://github.com/mozilla/mig/tree/master/doc
            #
            # note that modifying these files *will not* restart the agent service. push a new version
            # of the mig-agent package to force a restart, or call `kill -s 2 $(/sbin/mig-agent -q=pid)` which
            # will force upstart/systemd to respawn the agent after it is killed
            file {
                '/etc/mig/':
                    ensure => 'directory',
                    owner  => 'root',
                    mode   => '0755',
                    before => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/mig-agent.cfg':
                    content   => template('mig/mig-agent.cfg.erb'),
                    show_diff => false,
                    owner     => 'root',
                    mode      => '0600',
                    before    => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/ca.crt':
                    content   => template('mig/ca.crt.erb'),
                    show_diff => false,
                    owner     => 'root',
                    mode      => '0600',
                    before    => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/agent.crt':
                    content   => template('mig/agent.crt.erb'),
                    show_diff => false,
                    owner     => 'root',
                    mode      => '0600',
                    before    => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/agent.key':
                    content   => template('mig/agent.key.erb'),
                    show_diff => false,
                    owner     => 'root',
                    mode      => '0600',
                    before    => [ Class['packages::mozilla::mig_agent'] ];
            }
        }
        default: {
            fail("mig is not supported on ${::operatingsystem}")
        }
    }
}
