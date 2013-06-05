# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class buildmaster::release_runner_access {
    # give the release-runner key access to the builder user, so it
    # can reconfigure masters remotely
    users::builder::extra_authorized_key {
        'release-runner': ;
    }
}
