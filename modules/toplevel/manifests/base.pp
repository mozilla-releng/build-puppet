# All nodes should include a subclass of this class.  It sets up global
# parameters that apply to all releng hosts.

class toplevel::base {
    # Manage this in the packagesetup stage so that they are in place by the
    # time any Package resources are managed.
    class {
        'packages::setup': stage => packagesetup,
    }

    include puppet
    include users::root
    include users::global
    include network
    include sudoers
    include packages::editors
    include packages::screen
    include powermanagement
}
