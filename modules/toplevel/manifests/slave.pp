# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::slave inherits toplevel::base {
    include dirs::builds::slave
    include users::builder
    include puppet::atboot
    include sudoers::reboot
    include buildslave

    # packages common to all slaves
    include packages::mozilla::tooltool
    include packages::mozilla::py27_mercurial
    include packages::wget

    # apply tweaks
    include tweaks::dev_ptmx
    include tweaks::rc_local
    include tweaks::locale
    include disableservices::slave
}
