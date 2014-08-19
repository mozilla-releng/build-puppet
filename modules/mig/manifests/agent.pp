# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent {
    include packages::mozilla::mig_agent
    case $::operatingsystem {
        'CentOS', 'RedHat', 'Ubuntu': {
            # Package installation and service startup are performed in 'packages::mozilla::mig_agent'
            # the files below are used to provision secrets for the agent. More details can be found
            # in the doc at https://github.com/mozilla/mig/tree/master/doc
            #
            # note that modifying these files *will not* restart the agent service. push a new version
            # of the mig-agent package to force a restart, or call `kill $(/sbin/mig-agent -q=pid)` which
            # will force upstart/systemd to respawn the agent after it is killed
            file {
                '/etc/mig/':
                    ensure => 'directory',
                    owner => 'root',
                    mode => 755,
                    before => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/mig-agent.cfg':
                    content => template('mig/mig-agent.cfg.erb'),
                    owner => 'root',
                    mode => 600,
                    before => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/ca.crt':
                    content => template('mig/ca.crt.erb'),
                    owner => 'root',
                    mode => 600,
                    before => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/agent.crt':
                    content => template('mig/agent.crt.erb'),
                    owner => 'root',
                    mode => 600,
                    before => [ Class['packages::mozilla::mig_agent'] ];
                '/etc/mig/agent.key':
                    content => template('mig/agent.key.erb'),
                    owner => 'root',
                    mode => 600,
                    before => [ Class['packages::mozilla::mig_agent'] ];
            }
        }
    }
}
