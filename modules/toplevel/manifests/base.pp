# All nodes should include a subclass of this class.  It sets up global
# parameters that apply to all releng hosts.

class toplevel::base {
    include puppet
    include packages::setup
    include user::root
}
