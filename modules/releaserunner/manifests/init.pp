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
    include packages::make
    include packages::mysql_devel

    python::virtualenv {
        "${releaserunner::settings::root}":
            python   => "${packages::mozilla::python27::python}",
            require  => Class['packages::mozilla::python27'],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
            packages => [
                "Fabric==1.5.1",
                "Jinja2==2.6",
                "SQLAlchemy==0.8.0b2",
                "Tempita==0.5.1",
                "Twisted==12.3.0",
                "buildbot==0.8.7p1",
                "certifi==0.0.8",
                "decorator==3.4.0",
                "paramiko==1.9.0",
                "pycrypto==2.6",
                "python-dateutil==1.5",
                "simplejson==2.6.2",
                "sqlalchemy-migrate==0.7.2",
                "wsgiref==0.1.2",
                "zope.interface==4.0.2",
                "mercurial==2.5.4",
            ];
    }

    file {
        "${releaserunner::settings::root}/release-runner.ini":
            require => Python::Virtualenv["${releaserunner::settings::root}"],
            mode    => 0600,
            owner   => "${users::builder::username}",
            group   => "${users::builder::group}",
            content => template("releaserunner/release-runner.ini.erb");
    }

    mercurial::repo {
        "releaserunner-tools":
            require => Python::Virtualenv["${releaserunner::settings::root}"],
            hg_repo => "${config::releaserunner_tools}",
            dst_dir => "${releaserunner::settings::tools_dst}",
            user    => "${users::builder::username}",
            branch  => "${config::releaserunner_tools_branch}",
    }

}
