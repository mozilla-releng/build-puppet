# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::slave inherits toplevel::base {
    include users::builder
    include puppet::atboot
    include buildslave

    # apply tweaks
    include tweaks::dev-ptmx
}

