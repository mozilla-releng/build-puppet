# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::slave inherits toplevel::base {
    include dirs::builds::slave
    include users::builder
    include puppet::atboot
    include sudoers::reboot
    include buildslave

    # packages common to all slaves
    include packages::mozilla::tooltool
    include packages::mozilla::py27_mercurial
    include packages::wget

    # apply tweaks
    include tweaks::dev-ptmx
    include disableservices::slave
}

