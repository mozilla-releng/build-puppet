# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class smarthost::setup {
    include ::config

    file {
        "/etc/postfix/main.cf":
            owner => "postfix",
            group => "postfix",
            mode => 0644,
            ensure => present,
            content => template("smarthost/main.cf.erb"),
            require => Class["smarthost::install"],
            notify => Class["smarthost::daemon"];
        "/etc/aliases":
            source => "puppet:///modules/smarthost/aliases",
            require => Class['smarthost::install'],
            notify => Exec['newaliases'];
    }

    exec {
        'newaliases':
            command => "/usr/bin/newaliases",
            refreshonly => true;
    }
}
