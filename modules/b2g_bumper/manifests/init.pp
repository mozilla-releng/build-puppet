# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# b2g manifest bumper service
class b2g_bumper {
    include packages::mozilla::py27_mercurial
    include packages::mozilla::hgtool
    include packages::mozilla::gittool
    include packages::logrotate
    include packages::procmail # for lockfile
    include users::builder
    include dirs::builds

    $b2g_bumper_user = $::config::builder_username

    file {
        "/builds/b2g_bumper":
            owner  => $b2g_bumper_user,
            ensure => directory;

        "/usr/local/bin/run_b2g_bumper.sh":
            source => "puppet:///modules/b2g_bumper/run_b2g_bumper.sh",
            mode   => 0755,
            owner  => root;

        "/etc/cron.d/run_b2g_bumper":
            require => File["/usr/local/bin/run_b2g_bumper.sh"],
            content => template("b2g_bumper/run_b2g_bumper.cron.erb"),
            owner  => root;

        "/etc/logrotate.d/b2g_bumper":
            source => "puppet:///modules/b2g_bumper/logrotate_b2g_bumper",
            require => Class['packages::logrotate'];
    }
}
