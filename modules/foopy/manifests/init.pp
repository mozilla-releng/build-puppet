class foopy {
    include users::builder
    include dirs::builds
    include packages::net-snmp-utils
    include packages::nslookup
    include packages::rsync
    include packages::unzip
    include packages::mozilla::python26
    include packages::mozilla::python27
    include packages::mozilla::py27_mercurial
    include buildslave::install
    include foopy::repos

    include config

    file {
        # Set perms on these files properly, so that our automation can use them.
        ["/builds/tegra_status.txt",
         "/builds/check.log",
         "/builds/check2.log",
         "/builds/tegra_stats.log"]:
            owner => $config::builder_username,
            group => $config::builder_username,
            ensure => file,
            mode => 0644;

        # This will be created manually, but needs proper permissions, ensure them.
        "/builds/tegra_stats.sh":
            owner => $config::builder_username,
            group => $config::builder_username,
            ensure => file,
            mode => 0755;
            #content based on http://hg.mozilla.org/build/tools/raw-file/default/buildfarm/mobile/tegra_stats.sh.in

        # Link the helper scripts for humans to /builds
        "/builds/check.sh":
            owner => $config::builder_username,
            group => $config::builder_username,
            ensure => link,
            target => "/builds/tools/buildfarm/mobile/check.sh";
        "/builds/start_cp.sh":
            owner => $config::builder_username,
            group => $config::builder_username,
            ensure => link,
            target => "/builds/tools/buildfarm/mobile/start_cp.sh";
        "/builds/stop_cp.sh":
            owner => $config::builder_username,
            group => $config::builder_username,
            ensure => link,
            target => "/builds/tools/buildfarm/mobile/stop_cp.sh";
        "/builds/kill_stalled.sh":
            owner => $config::builder_username,
            group => $config::builder_username,
            ensure => link,
            target => "/builds/tools/buildfarm/mobile/kill_stalled.sh";

        # Attach needed cron jobs
        "/etc/cron.d/foopy":
            owner => root,
            group => root,
            ensure => file,
            content => template("foopy/foopy.crontab.erb"),
            require => [
                Class["foopy::repos"],
                File["/builds/tegra_stats.sh"],
                File["/builds/check.sh"],
                File["/builds/tegra_status.txt"],
                File["/builds/check.log"],
                File["/builds/check2.log"],
                File["/builds/tegra_stats.log"],
            ];
    }

    # apply tweaks
    include tweaks::dev-ptmx
}