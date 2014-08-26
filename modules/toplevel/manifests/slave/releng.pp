# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# All buildbot slaves (both build and test) are subclasses of this class.
class toplevel::slave::releng inherits toplevel::slave {
    include dirs::builds::slave
    include buildslave
    include instance_metadata

    # packages common to all slaves
    include packages::mozilla::tooltool
    include packages::mozilla::py27_mercurial
    include packages::wget
}
