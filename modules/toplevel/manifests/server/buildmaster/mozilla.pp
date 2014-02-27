# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# mozilla buildbot master

class toplevel::server::buildmaster::mozilla inherits toplevel::server::buildmaster {
    include buildmaster::base
    include buildmaster::release_runner_access
    include buildmaster::queue
    include buildmaster::settings
    include packages::procmail # for lockfile

    if $::virtual == "xenhvm" {
        # Bug 964880: make sure to enable swap on some instance types
        include tweaks::swap_on_instance_storage
    }
}
