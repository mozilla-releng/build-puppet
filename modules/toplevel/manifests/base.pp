# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All nodes should include a subclass of this class.  It sets up global
# parameters that apply to all releng hosts.

class toplevel::base {
    # Manage this in the packagesetup stage so that they are in place by the
    # time any Package resources are managed.
    class {
        'packages::setup': stage => packagesetup,
    }

    include users::root
    include users::global
    include network
    include sudoers
    include packages::editors
    include packages::screen
    include powermanagement
    include clean
    include hardware
    include ssh
    include timezone

    # the startup_type is overridden in child classes
    class {
        puppet:
            startup_type => 'none';
    }
}
