# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class mozpool::daemon {
    include packages::httpd
    include mozpool::settings
    include mozpool::virtualenv

    # run the daemon on port 8010; Apache will proxy there
    supervisord::supervise {
      "mozpool-server":
        command => "${::mozpool::settings::root}/frontend/bin/mozpool-server 8010",
        user => 'apache',
        environment => [ "MOZPOOL_CONFIG=${::mozpool::settings::config_ini}" ],
        require => [
            Class['mozpool::virtualenv'],
            Class['packages::httpd'],
        ],
        extra_config => "stderr_logfile=/var/log/mozpool.log\nstderr_logfile_maxbytes=10MB\nstderr_logfile_backups=10\n";
    }

    # create a place for mozpool to log its heartbeats; see bug 838925
    file {
        "/var/run/mozpool":
            ensure => directory,
            owner => 'apache',
            group => 'apache',
            require => Class['packages::httpd'];
    }
}
