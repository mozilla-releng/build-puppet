# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# All TaskCluster workers are subclasses of this class.

class toplevel::worker inherits toplevel::base {
    include disableservices::slave
    include puppet::atboot
    include sudoers::reboot
    include users::builder

    # apply tweaks
    include tweaks::dev_ptmx
    include tweaks::locale

    case $::operatingsystem {
        'Darwin': {
            include users::root::autologin
        }

        default: {
            fail("worker not (yet) supported on ${::operatingsystem}")
        }
    }
}
