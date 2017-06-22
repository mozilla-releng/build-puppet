# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class slaverebooter {
    include ::config
    include dirs::builds
    include users::builder
    include slaverebooter::settings
    include slaverebooter::services
    include packages::mozilla::python27

    $basedir  = $slaverebooter::settings::root
    $python   = $packages::mozilla::python27::python
    $slaveapi = $config::slaverebooter_slaveapi

    python::virtualenv {
        $basedir:
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            packages => [
                            'furl==0.3.5',
                            'requests==1.2.3',
                            'docopt==0.6.1',
                            'buildtools==1.0.6',
                            'orderedmultidict==0.7.1',
            ];
    }

    file {
        $slaverebooter::settings::config:
            require => Python::Virtualenv[$basedir],
            owner   => $users::builder::username,
            group   => $users::builder::group,
            content => template('slaverebooter/slaverebooter.ini.erb');
    }
}
