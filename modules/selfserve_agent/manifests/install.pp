# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class selfserve_agent::install {
    include ::config
    include dirs::builds
    include users::builder
    include packages::mozilla::python27
    include packages::gcc
    include packages::make
    include packages::mysql_devel
    include selfserve_agent::settings

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "/usr/bin/supervisorctl stop selfserve-agent",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python27'];
    }

    python::virtualenv {
        $selfserve_agent::settings::root:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => Class['packages::mozilla::python27'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => file("selfserve_agent/requirements.txt");
    }
}
