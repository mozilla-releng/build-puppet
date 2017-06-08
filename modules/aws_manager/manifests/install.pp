# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class aws_manager::install {
    include ::config
    include dirs::builds
    include users::buildduty
    include packages::gcc
    include packages::make
    include packages::mercurial
    include packages::mysql_devel
    include packages::mozilla::python27
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::py27_mercurial
    include aws_manager::settings

    python::virtualenv {
        $aws_manager::settings::root:
            python   => $packages::mozilla::python27::python,
            require  => Class['packages::mozilla::python27'],
            user     => $users::buildduty::username,
            group    => $users::buildduty::group,
            packages => [
                'Fabric==1.8.0',
                'IPy==0.81',
                'MySQL-python==1.2.5',
                'SQLAlchemy==0.8.3',
                'argparse==1.2.1',
                'boto==2.27.0',
                'ecdsa==0.10',
                'invtool==4.4',
                'iso8601==0.1.10',
                'paramiko==1.12.0',
                'pycrypto==2.6.1',
                'repoze.lru==0.6',
                'requests==2.0.1',
                'simplejson==3.3.1',
                'ssh==1.8.0',
                'wsgiref==0.1.2',
                'docopt==0.6.1',
                'netaddr==0.7.12',
                'cfn-pyplates>=0.5.0',
                'PyYAML==3.11',
                'dnspython==1.12.0',
                'pbr==0.10.7',
                'ordereddict==1.1',
                'schema==0.3.1',
                'redo==1.4',
            ];
    }
    git::repo {
        "cloud-tools-${aws_manager::settings::cloud_tools_dst}":
            require => Python::Virtualenv[$aws_manager::settings::root],
            repo    => $config::cloud_tools_git_repo,
            dst_dir => $aws_manager::settings::cloud_tools_dst,
            user    => $users::buildduty::username;
    }
    exec {
        'install-cloud-tools-dist':
            command => "${aws_manager::settings::root}/bin/pip install -e ${aws_manager::settings::cloud_tools_dst}",
            user    => $users::buildduty::username,
            require => Git::Repo["cloud-tools-${aws_manager::settings::cloud_tools_dst}"];
    }
    file {
        "${aws_manager::settings::root}/bin":
            ensure  => directory,
            mode    => '0755',
            owner   => $users::buildduty::username,
            group   => $users::buildduty::group,
            require => Python::Virtualenv[$aws_manager::settings::root];
        '/etc/invtool.conf':
            source => "puppet:///modules/${module_name}/invtool.conf";
        $aws_manager::settings::cloudtrail_logs_dir:
            ensure => directory,
            owner  => $users::buildduty::username,
            group  => $users::buildduty::group;
        $aws_manager::settings::events_dir:
            ensure => directory,
            owner  => $users::buildduty::username,
            group  => $users::buildduty::group;
    }
}
