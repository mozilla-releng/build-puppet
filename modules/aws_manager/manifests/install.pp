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
            python          => $packages::mozilla::python27::python,
            rebuild_trigger => Class['packages::mozilla::python27'],
            require         => Class['packages::mozilla::python27'],
            user            => $users::buildduty::username,
            group           => $users::buildduty::group,
            packages        => file("aws_manager/requirements.txt");
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
            # no-deps because we already installed everything based on the requirements file above,
            # and either pip or the cloud tools setup.py gets too aggressive and pulls in broken stuff
            command => "${aws_manager::settings::root}/bin/pip install --no-deps -e ${aws_manager::settings::cloud_tools_dst}",
            user    => $users::buildduty::username,
            require => Git::Repo["cloud-tools-${aws_manager::settings::cloud_tools_dst}"];
    }
    file {
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
