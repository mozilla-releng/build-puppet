class toplevel::slave::build inherits toplevel::slave {
    include dirs::builds
    include dirs::builds::slave
    include dirs::builds::hg-shared
    include ntp::daemon
    include packages::mozilla-tools
}

