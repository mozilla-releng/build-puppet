# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::slave::releng inherits toplevel::slave {
    include dirs::builds::slave
    include users::builder
    include sudoers::reboot
    include buildslave

    # packages common to all slaves
    include packages::mozilla::tooltool
    include packages::mozilla::py27_mercurial
    include packages::wget

    # apply tweaks
    include tweaks::dev_ptmx
    include tweaks::locale
    include disableservices::slave

    # *all* Darwin slaves need to autologin, not just testers
    if ($::operatingsystem == "Darwin") {
        include users::builder::autologin
    }
}
