# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class buildslave::startup::initd {
    file {
        "/etc/init.d/buildbot":
            content => template("buildslave/linux-initd-buildbot.sh.erb"),
            owner  => "root",
            group  => "root",
            mode => 755,
            notify => Exec['initd-bb-refresh'];
    }
    exec {
        'initd-bb-refresh':
            # resetpriorities tells chkconfig to update the
            # symlinks in rcX.d with the values from the service's
            # init.d script
            command => '/sbin/chkconfig buildbot resetpriorities',
            refreshonly => true;
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
