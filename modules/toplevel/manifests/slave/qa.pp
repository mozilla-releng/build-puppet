# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# All buildbot slaves (both build and test) are subclasses of this class.

# All QA slaves (both mozmill-ci and tps-ci) are subclasses of this class.
class toplevel::slave::qa inherits toplevel::slave {
    include vnc

    include packages::java

    class {
        gui:
            on_gpu => true,
            screen_width => 1024,
            screen_height => 768,
            screen_depth => 32,
            refresh => 60;
    }
}
