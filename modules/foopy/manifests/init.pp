# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class foopy {
    include users::builder
    include dirs::builds
    include packages::net_snmp_utils
    include packages::nslookup
    include packages::rsync
    include packages::unzip
    include packages::alsa
    include packages::pango
    include packages::patch
    include packages::procmail # for lockfile
    include packages::gtk2
    include packages::telnet
    include packages::x_libs
    include packages::ia32libs  # for szip host binary
    include packages::mozilla::python26
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include buildslave::install
    include disableservices::iptables
    include foopy::repos
    include tweaks::dev_ptmx

    include config

    file {
        # Set perms on these files properly, so that our automation can use them.
        ["/builds/watcher.log"]:
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => file,
            mode => 0644;

        # Link the helper scripts for humans to /builds
        "/builds/watch_devices.sh":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/builds/tools/buildfarm/mobile/watch_devices.sh";
        
        # Symlink minidump_stackwalk to tools repo, needed only until we drop
        # OSX Foopies
        "/builds/minidump_stackwalk":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/builds/tools/breakpad/linux64/minidump_stackwalk";

        # Attach needed cron jobs
        "/etc/cron.d/foopy":
            owner => root,
            group => root,
            ensure => file,
            content => template("foopy/foopy.crontab.erb"),
            require => [
                Class["foopy::repos"],
                File["/builds/watch_devices.sh"],
            ];

        # Directory for rolled log files of watcher.log
        "/builds/watcher_rolled_logs":
            ensure => directory,
            owner => $users::builder::username,
            group => $users::builder::group,
            mode   => 775;
        # Logrotate for watch_devices.sh logs
        "/etc/logrotate.d/watch_devices":
            owner => root,
            group => root,
            ensure => file,
            content => template("foopy/foopy.logrotate.erb");
        # Link to logrotate config, for ease of understanding for users
        "/builds/logrotate.config":
            owner => $users::builder::username,
            group => $users::builder::group,
            ensure => link,
            target => "/etc/logrotate.d/watch_devices",
            require => File['/etc/logrotate.d/watch_devices'];
    }
    
    # Obsolete
    file {
        # Bug 875599: these files should no longer exist
        ["/builds/start_cp.sh",
         "/builds/stop_cp.sh",
         "/builds/check.sh",
         "/builds/tegra_status.txt",
         "/builds/check.log",
         "/builds/check2.log",
         "/builds/tegra_stats.log"]:
            ensure => absent;
    }
}
