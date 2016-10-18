# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class toplevel::worker::releng::test::gpu inherits toplevel::worker::releng::test {
    class {
        gui:
            on_gpu => true,
            screen_width => 1600,
            screen_height => 1200,
            screen_depth => 32,
            refresh => 60;
    }
}
