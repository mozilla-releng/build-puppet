# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::slave inherits toplevel::base {
    include users::builder
    include puppet::atboot
    include buildslave

    # packages common to all slaves
    include packages::tooltool

    # apply tweaks
    include tweaks::dev-ptmx
}

