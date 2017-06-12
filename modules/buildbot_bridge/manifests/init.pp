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
    include packages::mozilla::python35
    include packages::mysql_devel
    include users::builder

    $bbb_version = $::buildbot_bridge::settings::env_config['version']

    python::virtualenv {
        $buildbot_bridge::settings::root:
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            packages => [
                # Taskcluster pins requests 2.4.3, so we need to de the same,
                # even though we'd rather use a more up-to-date version.
                'requests==2.4.3',
                'arrow==0.5.4',
                'taskcluster==0.0.26',
                'sqlalchemy==1.0.0',
                'kombu==3.0.24',
                'redo==1.4',
                'mysql-python==1.2.5',
                'amqp==1.4.6',
                'python-dateutil==2.4.2',
                'pytz==2015.2',
                'six==1.9.0',
                'wsgiref==0.1.2',
                'PyHawk-with-a-single-extra-commit==0.1.5',
                'anyjson==0.3.3',
                'PyYAML==3.10',
                'jsonschema==2.4.0',
                'slugid==1.0.6',
                'statsd==3.2.1',
                "bbb==${bbb_version}",
            ];
    }
}
