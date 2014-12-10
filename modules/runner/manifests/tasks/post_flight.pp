# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

# Halt runner under certain conditions
class runner::tasks::post_flight($runlevel=99) {
    include runner

    runner::task {
        "${runlevel}-post_flight":
            source => 'puppet:///modules/runner/post_flight.py';
    }
}
