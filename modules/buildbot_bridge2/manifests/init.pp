# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildbot_bridge2 {
    include ::config
    include buildbot_bridge2::services
    include buildbot_bridge2::settings
    include packages::mozilla::python3
    include dirs::builds
    include users::builder

    $bbb_version = $::buildbot_bridge2::settings::env_config['version']
    $external_packages = file("buildbot_bridge2/requirements.txt")
    $packages = "${external_requirements}\nbbb==${bbb_version}"

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-reflector":
            command     => "/usr/bin/supervisorctl stop reflector",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python3'];
    }

    python3::virtualenv {
        $buildbot_bridge2::settings::root:
            python3         => $packages::mozilla::python3::python3,
            rebuild_trigger => Exec["stop-for-rebuild-reflector"],
            require         => Class['packages::mozilla::python3'],
            user            => $users::builder::username,
            group           => $users::builder::group,
            mode            => '0700',
            packages        => $packages;
    }
}
