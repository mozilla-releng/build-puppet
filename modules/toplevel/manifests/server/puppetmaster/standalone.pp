# toplevel class for running a standalone puppet master
class toplevel::server::puppetmaster::standalone inherits toplevel::server::puppetmaster {
    include ::puppetmaster::standalone
}
