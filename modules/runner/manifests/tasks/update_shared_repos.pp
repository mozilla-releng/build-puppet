# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Make sure runner runs at boot
class runner::tasks::update_shared_repos($runlevel=3) {
    include runner

    runner::task {
        "${runlevel}-update_shared_repos":
            content  => template("${module_name}/tasks/update_shared_repos.erb");
    }
}
