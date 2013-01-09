# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildslave::startup::initd {
    file {
        "/etc/init.d/buildbot":
            content => template("buildslave/linux-initd-buildbot.sh.erb"),
            owner  => "root",
            group  => "root",
            mode => 755;
    }

    service {
        "buildbot":
            enable => true,
            require => [
                File['/etc/init.d/buildbot'],
                File['/usr/local/bin/runslave.py'],
                Class['buildslave::install'],
            ];
    }
}
