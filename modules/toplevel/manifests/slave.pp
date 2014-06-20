# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All buildbot slaves (both build and test) are subclasses of this class.

class toplevel::slave inherits toplevel::base {
    include disableservices::slave
    include puppet::atboot
    include sudoers::reboot
    include users::builder

    # apply tweaks
    include tweaks::dev_ptmx
    include tweaks::locale

    # *all* Darwin slaves need to autologin, not just testers
    if ($::operatingsystem == "Darwin") {
        include users::builder::autologin
    }
}
