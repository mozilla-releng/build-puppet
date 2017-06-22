# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# runner module
class runner {
    include ::config
    include dirs::opt
    include runner::service
    include runner::settings
    include packages::mozilla::python27
    if ($::operatingsystem == Windows) {
        include packages::mozilla::mozilla_build
    }

    $runner_service = $::operatingsystem ? {
        windows => Exec['startrunner'],
        default => Service['runner'],
    }
    # When Puppet sets the mode on Windows it causes ACL permissions to be stripped rendering the file unusable
    $mode  = $::operatingsystem ? {
        windows => undef,
        default => '0755',
    }
    python::virtualenv {
        $runner::settings::root:
            python   => $packages::mozilla::python27::python,
            require  => [Class['packages::mozilla::python27'],
                            Class['dirs::opt']
                        ],
            packages => [
                'runner==2.0',
            ];
    }
    file {
        $runner::settings::taskdir:
            ensure  => directory,
            force   => true,
            recurse => true,
            purge   => true;
        "${runner::settings::root}/runner.cfg":
            before    => $runner_service,
            content   => template('runner/runner.cfg.erb'),
            show_diff => false;
    }
    case $::operatingsystem {
        'CentOS', 'Ubuntu': {
            file {
                '/etc/logrotate.d/runner':
                    mode    => '0644',
                    content => template('runner/runner.logrotate.erb');
            }
        }
    }
}
