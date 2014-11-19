# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Populate shared repos
class runner::tasks::populate_shared_repos($runlevel=3) {
    include runner

    runner::task {
        "${runlevel}-populate_shared_repos":
            content  => template("${module_name}/tasks/populate_shared_repos.erb");
    }
}
