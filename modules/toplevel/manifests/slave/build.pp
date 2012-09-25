class toplevel::slave::build inherits toplevel::slave {
    include dirs::builds
    include dirs::builds::slave
    include dirs::builds::hg-shared

    include users::builder

    include ntp::daemon
    include tweaks::nofile

    include nrpe::check::buildbot
    include nrpe::check::ide_smart
    include nrpe::check::procs_regex
    include nrpe::check::child_procs_regex

    include packages::mozilla::git
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::hgtool

    ccache::ccache_dir {
        "/builds/ccache":
            maxsize => "10G",
            owner => $users::builder::username;
    }
}
