# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class toplevel::slave::test inherits toplevel::slave {
    # test slaves need a GUI, and to be logged in.  For now they're just Darwin,
    # so we get the GUI for free and just need to ensure VNC is enabled.
    include vnc
    include screenresolution::talos
    include packages::linux_desktop
    include users::builder::autologin
    include talos
    include ntp::atboot
    include packages::fonts
    include tweaks::fonts
    include tweaks::cleanup
}
