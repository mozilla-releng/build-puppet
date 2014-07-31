# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# runner module
class runner {
    include ::config
    include runner::service
    include runner::settings
    include packages::mozilla::python27

    python::virtualenv {
        $runner::settings::root:
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            packages => [
                'runner==1.1',
            ];
    }

    file {
        $runner::settings::taskdir:
            ensure => directory,
            force  => true,
            purge  => true;
        "${runner::settings::root}/runner.cfg":
            before  => Service['runner'],
            content => template('runner/runner.cfg.erb');
    }

    file {
        '/etc/logrotate.d/runner':
            mode => '0644',
            content => template('runner/runner.logrotate.erb');
    }
}
