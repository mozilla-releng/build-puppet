# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mig::agent {
    include ::config
    if ($::config::enable_mig_agent) {
        case $::operatingsystem {
            'CentOS', 'RedHat': {
                realize(Packages::Yumrepo['mig-agent'])
            }
            'Ubuntu': {
                realize(Packages::Aptrepo['mig-agent'])
            }
        }

        case $::operatingsystem {
            'CentOS', 'RedHat', 'Ubuntu': {
                package {
                    "mig-agent":
                        ensure => latest,
                        require => [ File['/etc/mig/mig-agent.cfg'],
                                     File['/etc/mig/ca.crt'],
                                     File['/etc/mig/agent.crt'],
                                     File['/etc/mig/agent.key']
                                   ];
                }
                file {
                    "/etc/mig/":
                        ensure => "directory",
                        owner => "root",
                        mode => 755;
                    "/etc/mig/mig-agent.cfg":
                        content => template("mig/mig-agent.cfg.erb"),
                        owner => "root",
                        mode => 600;
                    "/etc/mig/ca.crt":
                        content => template("mig/ca.crt.erb"),
                        owner => "root",
                        mode => 600;
                    "/etc/mig/agent.crt":
                        content => template("mig/agent.crt.erb"),
                        owner => "root",
                        mode => 600;
                    "/etc/mig/agent.key":
                        content => template("mig/agent.key.erb"),
                        owner => "root",
                        mode => 600;
                }
            }
            default: {
                fail("cannot install on $::operatingsystem")
            }
        }
    }
}
