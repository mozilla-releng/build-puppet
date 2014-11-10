# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::tasks::darwin_clean_buildbot($runlevel=0) {
    include runner

    runner::task {
        "${runlevel}-darwin_clean_buildbot":
            source  => 'puppet:///modules/runner/darwin-clean-buildbot.sh';
    }
}
