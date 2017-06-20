# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class tweaks::dev_ptmx {
    # See https://bugzilla.mozilla.org/show_bug.cgi?id=568035
    # It's not clear how this file's permission might get changed, but this
    # will ensure it's correct.  This seems applicable for all Linux versions,
    # although it has not been tested on Ubuntu.

    case $::kernel {
        Linux: {
            file {
                '/dev/ptmx':
                    mode  => '0666',
                    owner => 'root',
                    group => 'tty';
            }
        }
    }
}
