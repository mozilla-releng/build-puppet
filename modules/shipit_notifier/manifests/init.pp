# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class shipit_notifier {
    include ::config
    include dirs::builds
    include users::builder
    include shipit_notifier::settings
    include shipit_notifier::services
    include packages::mozilla::python27

    python::virtualenv {
        "${shipit_notifier::settings::root}":
            python   => "${packages::mozilla::python27::python}",
            require  => Class['packages::mozilla::python27'],
            user     => "${users::builder::username}",
            group    => "${users::builder::group}",
            packages => [
                "MozillaPulse==1.0",
                "amqp==1.4.3",
                "anyjson==0.3.3",
                "certifi==0.0.8",
                "kombu==3.0.12",
                "python-dateutil==2.2",
                "pytz==2013.7",
                "six==1.8.0",
            ];
    }

    file {
        "${shipit_notifier::settings::root}/shipit_notifier.ini":
            require => Python::Virtualenv["${shipit_notifier::settings::root}"],
            mode    => 0600,
            owner   => "${users::builder::username}",
            group   => "${users::builder::group}",
            content => template("shipit_notifier/shipit_notifier.ini.erb"),
            show_diff => false;
    }

    mercurial::repo {
        "shipit_notifier_tools":
            require => Python::Virtualenv["${shipit_notifier::settings::root}"],
            hg_repo => "${config::shipit_notifier_tools}",
            dst_dir => "${shipit_notifier::settings::tools_dst}",
            user    => "${users::builder::username}",
            branch  => "${config::shipit_notifier_tools_branch}",
    }
}
