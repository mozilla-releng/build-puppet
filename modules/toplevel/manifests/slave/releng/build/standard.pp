# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::slave::releng::build::standard inherits toplevel::slave::releng::build {
    include ::config
    include users::builder

    if ($::operatingsystem == "Darwin") {
        include packages::xcode
        include packages::yasm
        include packages::autoconf
        include packages::p7zip
        include packages::libpng

        # used for partner repacks, which only run on OS X
        include packages::upx

        # and since OS X has a GUI enabled all the time, set up VNC and set the
        # screen resolution; sources suggest that the actual build process
        # doesn't care about the resolution, and that this is merely for user
        # convenience
        class {
            'vnc':
                ;
            'screenresolution':
                width => 1024,
                height => 768,
                depth => 32,
                refresh => 60;
        }
    }
}
