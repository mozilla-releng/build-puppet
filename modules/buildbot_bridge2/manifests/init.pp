# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildbot_bridge2 {
    include ::config
    include buildbot_bridge2::services
    include buildbot_bridge2::settings
    include packages::mozilla::python35
    include dirs::builds
    include users::builder

    $bbb_version = $::buildbot_bridge2::settings::env_config['version']

    python35::virtualenv {
        $buildbot_bridge2::settings::root:
            python3  => $packages::mozilla::python35::python3,
            require  => Class['packages::mozilla::python35'],
            user     => $users::builder::username,
            group    => $users::builder::group,
            mode     => '0700',
            packages => [
                "bbb==${bbb_version}",
                'aiohttp==1.3.5',
                'appdirs==1.4.3',
                'arrow==0.10.0',
                'async-timeout==1.2.0',
                'chardet==2.3.0',
                'click==6.7',
                'jsonschema==2.6.0',
                'mohawk==0.3.4',
                'multidict==2.1.4',
                'mysql-connector-python==2.0.4',
                'py==1.4.33',
                'pyparsing==2.2.0',
                'python-dateutil==2.6.0',
                'PyYAML==3.12',
                'Represent==1.5.1',
                'requests==2.13.0',
                'six==1.10.0',
                'slugid==1.0.7',
                'SQLAlchemy==1.1.7',
                'sqlalchemy-aio==0.11.0',
                'statsd==3.2.1',
                'taskcluster==1.2.0',
                'yarl==0.9.8',
            ];
    }
}
