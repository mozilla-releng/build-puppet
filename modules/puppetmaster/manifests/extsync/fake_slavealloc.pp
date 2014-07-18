# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class puppetmaster::extsync::fake_slavealloc($ensure) {
    # This is designed to host a place for a slave list, like
    # puppetmaster::extsync::slavealloc, since without an extsync to use
    # there will be no hiera import.
}
