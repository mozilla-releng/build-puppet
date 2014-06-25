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
        default: {
            fail("Unsupported OS ${::operatingsystem}")
        }
    }
}
