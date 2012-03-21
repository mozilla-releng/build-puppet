class toplevel::slave::build inherits toplevel::slave {
    include dirs::builds
    include dirs::builds::slave
    include dirs::builds::hg-shared
    include ntp::daemon
    include packages::mozilla-tools
    include tweaks::nofile
    include sudoers
    class { 'packages::environment':
        path_additions => ['/tools/git/bin/', '/tools/python27/bin/', '/tools/python27-mercurial/bin'],
    }
    include packages::environment
}
