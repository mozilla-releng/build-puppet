# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Take care of all pending clobbers
class runner::tasks::clobber($runlevel=3) {
    include runner

    runner::task {
        "${runlevel}-clobber":
            source => 'puppet:///modules/runner/clobber.sh';
    }
}
