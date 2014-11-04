# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::service {
    include runner::settings
    case $::operatingsystem {
        'CentOS': {
            file {
                '/etc/init.d/runner':
                    content => template('runner/runner.initd.erb'),
                    mode    => '0755',
                    notify  => Exec['initd-r-refresh'];
            }
            exec {
                'initd-r-refresh':
                    # resetpriorities tells chkconfig to update the
                    # symlinks in rcX.d with the values from the service's
                    # init.d script
                    command => '/sbin/chkconfig runner resetpriorities',
                    refreshonly => true;
            }
            service {
                'runner':
                    require   => [
                        Python::Virtualenv[$runner::settings::root],
                    ],
                    hasstatus => false,
                    enable    => true;
            }
        }
        'Ubuntu': {
            file {
                "/etc/init/runner.conf":
                    content => template("runner/runner.upstart.conf.erb");
            }
            service {
                'runner':
                    require   => [
                        Python::Virtualenv[$runner::settings::root],
                        File["/etc/init/runner.conf"],
                    ],
                    hasstatus => false,
                    enable    => true;
            }
        }
        'Darwin': {
            file {
                "/Library/LaunchDaemons/com.mozilla.runner.plist":
                    owner => root,
                    group => wheel,
                    mode => 0644,
                    content => template("runner/runner.plist.erb");
            }
            service {
                "runner":
                    require   => [
                        Python::Virtualenv[$runner::settings::root],
                        File["/Library/LaunchDaemons/com.mozilla.runner.plist"],
                    ],
                    hasstatus => false,
                    enable    => true;
            }
        }
        default: {
            fail("Unsupported OS ${::operatingsystem}")
        }
    }
}
