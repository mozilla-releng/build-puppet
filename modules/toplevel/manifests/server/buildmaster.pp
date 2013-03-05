# buildbot master

class toplevel::server::buildmaster inherits toplevel::server {

    include nrpe::base
    include users::builder
    include dirs::builds::buildbot
    include packages::gcc
    include packages::make
    include packages::mercurial
    include packages::mysql-devel
    include packages::mozilla::git
    include packages::mozilla::python27
    include packages::mozilla::py27_virtualenv
    include packages::mozilla::py27_mercurial
    include buildmaster
}

