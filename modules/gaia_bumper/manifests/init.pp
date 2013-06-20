# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# gaia bumper service
class gaia_bumper {
    include packages::mozilla::py27_mercurial
    include packages::mozilla::hgtool
    include packages::logrotate
    include packages::procmail # for lockfile
    include users::builder
    include dirs::builds

    $gaia_bumper_user = $::config::builder_username

    file {
        "/builds/gaia_bumper":
            owner  => $gaia_bumper_user,
            ensure => directory;

        "/usr/local/bin/run_gaia_bumper.sh":
            source => "puppet:///modules/gaia_bumper/run_gaia_bumper.sh",
            mode   => 0755,
            owner  => root;

        "/etc/cron.d/run_gaia_bumper":
            require => File["/usr/local/bin/run_gaia_bumper.sh"],
            content => template("gaia_bumper/run_gaia_bumper.cron.erb"),
            owner  => root;

        "/etc/logrotate.d/gaia_bumper":
            source => "puppet:///modules/gaia_bumper/logrotate_gaia_bumper",
            require => Class['packages::logrotate'];
    }
}
