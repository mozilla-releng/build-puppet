# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildbot_bridge {
    include ::config
    include buildbot_bridge::services
    include buildbot_bridge::settings
    include dirs::builds
    include packages::gcc
    include packages::make
    include packages::mozilla::python27
    include packages::mozilla::python3
    include packages::mysql_devel
    include users::builder

    $bbb_version = $::buildbot_bridge::settings::env_config['version']

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-bblistener":
            command     => "/usr/bin/supervisorctl stop bblistener",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python27'];
    }
    exec {
        "stop-for-rebuild-tclistener":
            command     => "/usr/bin/supervisorctl stop tclistener",
            refreshonly => true,
            subscribe   => Exec["stop-for-rebuild-bblistener"],
    }

    $external_packages = file("buildbot_bridge/requirements.txt")
    $packages = "${external_packages}\nbbb==${bbb_version}"

    python::virtualenv {
        $buildbot_bridge::settings::root:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Exec["stop-for-rebuild-tclistener"],
            require         => Class['packages::mozilla::python27'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            packages        => $packages;
    }
}
