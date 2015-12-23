# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# seamonkey buildbot master

class toplevel::server::buildmaster::seamonkey inherits toplevel::server::buildmaster {
    include buildmaster::base
    include buildmaster::queue
    include buildmaster::settings
    include packages::procmail # for lockfile
}
