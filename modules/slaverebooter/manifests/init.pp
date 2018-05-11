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
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => Class['packages::mozilla::python27'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => file("slaverebooter/requirements.txt");
    }

    file {
        $slaverebooter::settings::config:
            require => Python::Virtualenv[$basedir],
            owner   => $users::builder::username,
            group   => $users::builder::group,
            content => template('slaverebooter/slaverebooter.ini.erb');
    }
}
