# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class releaserunner {
    include ::config
    include dirs::builds
    include users::builder
    include releaserunner::settings
    include releaserunner::services
    include packages::mozilla::python27
    include packages::gcc
    include packages::libffi
    include packages::make
    include packages::mysql_devel

    $env_config = $config::releaserunner_env_config[$releaserunner_env]

    python::virtualenv {
        $releaserunner::settings::root:
            python   => $packages::mozilla::python27::python,
            require  => [
                Class['packages::mozilla::python27'],
                Class['packages::libffi'],
            ],
            user     => $users::builder::username,
            group    => $users::builder::group,
            packages => [
                'Fabric==1.5.1',
                'Jinja2==2.6',
                'PGPy==0.3.0',
                'PyHawk-with-a-single-extra-commit==0.1.5',
                'PyYAML==3.10',
                'SQLAlchemy==0.8.0b2',
                'Tempita==0.5.1',
                'Twisted==12.3.0',
                'arrow==0.5.4',
                'buildbot==0.8.7p1',
                'certifi==0.0.8',
                'chunkify==1.2',
                'cryptography==0.6',
                'decorator==3.4.0',
                'ecdsa==0.10',
                'enum34==1.0.4',
                'mohawk==0.3.1',
                'paramiko==1.9.0',
                'pycrypto==2.6.1',
                'python-dateutil==1.5',
                'python-jose==0.5.2',
                'redo==1.5',
                'releasetasks==0.3.3',
                'requests==2.6.0',
                'requests-hawk==1.0.0',
                'simplejson==2.6.2',
                'singledispatch==3.4.0.3',
                'six==1.9.0',
                'sqlalchemy-migrate==0.7.2',
                'taskcluster==0.0.24',
                'wsgiref==0.1.2',
                'zope.interface==4.0.2',
            ];
    }

    file {
        "${releaserunner::settings::root}/release-runner.ini":
            require   => Python::Virtualenv[$releaserunner::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template('releaserunner/release-runner.ini.erb'),
            show_diff => false;
        "${releaserunner::settings::root}/release-runner.yml":
            require   => Python::Virtualenv[$releaserunner::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => template('releaserunner/release-runner.yml.erb'),
            show_diff => false;
        "${users::builder::home}/.ssh/release-runner":
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => secret('releaserunner_ssh_key'),
            show_diff => false;
        "${releaserunner::settings::root}/docker-worker-pub.pem":
            require => Python::Virtualenv[$releaserunner::settings::root],
            owner   => $users::builder::username,
            group   => $users::builder::group,
            source  => "puppet:///modules/${module_name}/docker-worker-pub.pem";
        # XXX: Todo name funsize_signing_pvt_key better for current use-case
        "${releaserunner::settings::root}/id_rsa":
            require   => Python::Virtualenv[$releaserunner::settings::root],
            mode      => '0600',
            owner     => $users::builder::username,
            group     => $users::builder::group,
            content   => secret('funsize_signing_pvt_key'),
            show_diff => false;
    }

    mercurial::repo {
        'releaserunner-tools':
            require => Python::Virtualenv[$releaserunner::settings::root],
            hg_repo => $config::releaserunner_tools,
            dst_dir => $releaserunner::settings::tools_dst,
            user    => $users::builder::username,
            branch  => $config::releaserunner_tools_branch,
    }
}
