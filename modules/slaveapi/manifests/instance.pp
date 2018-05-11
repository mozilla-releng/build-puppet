# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

define slaveapi::instance($listenaddr, $port, $version='1.6.8') {
    include config
    include slaveapi::base
    include users::builder

    # give slaveapi aws powers
    class {
        'slaveapi::aws':
            environment => $title,
    }

    $basedir          = "${slaveapi::base::root}/${title}"
    $credentials_file = "${basedir}/credentials.json"
    $config_file      = "${basedir}/slaveapi.ini"

    if (has_aspect('dev')) {
        $bugzilla_url = $::config::slaveapi_bugzilla_dev_url
    }
    else {
        $bugzilla_url = $::config::slaveapi_bugzilla_prod_url
    }

    motd {
        "slaveapi-${title}":
            content => "* port ${port} in ${basedir}\n",
            order   => 91;
    }

    $user  = $users::builder::username
    $group = $users::builder::group

    # If the Python installation changes, we need to rebuild the virtualenv
    # from scratch. Before doing that, we need to stop the running instance.
    exec {
        "stop-for-rebuild-${module_name}":
            command     => "${basedir}/bin/slaveapi-server.py stop ${config_file}",
            refreshonly => true,
            subscribe   => Class['packages::mozilla::python27'];
    }

    $external_packages = file("slaveapi/requirements.txt")
    $packages = "${external_packages}slaveapi==${version}"

    python::virtualenv {
        $basedir:
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Exec["stop-for-rebuild-${module_name}"],
            require         => [
                Class['packages::mozilla::python27'],
                Class['packages::libevent'],
                $slaveapi::base::compiler_req, # for compiled extensions
            ],
            user            => $user,
            group           => $group,
            packages        => $packages;
    }

    file {
        $config_file:
            content => template('slaveapi/slaveapi.ini.erb'),
            owner   => $user,
            group   => $group,
            notify  => Exec["${title}-reload-slaveapi-server"],
            require => Python::Virtualenv[$basedir];
        $credentials_file:
            content   => template('slaveapi/credentials.json.erb'),
            owner     => $user,
            group     => $group,
            notify    => Exec["${title}-reload-slaveapi-server"],
            require   => Python::Virtualenv[$basedir],
            show_diff => false;
    }

    exec {
        "${title}-reload-slaveapi-server":
            command     => "${basedir}/bin/slaveapi-server.py reload ${config_file}",
            cwd         => $basedir,
            user        => $user,
            onlyif      => "/bin/sh -c 'test -e ${basedir}/slaveapi.pid'",
            refreshonly => true;
        "${title}-start-slaveapi-server":
            command => "${basedir}/bin/slaveapi-server.py start ${config_file}",
            cwd     => $basedir,
            user    => $user,
            require => [
                Python::Virtualenv[$basedir],
                File[$config_file],
                File[$credentials_file],
            ],
            unless  => "/bin/sh -c 'test -e ${basedir}/slaveapi.pid'";
    }
}
