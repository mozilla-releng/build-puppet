# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# Cleanup
class runner::tasks::cleanup($runlevel=1) {
    include runner

    runner::task {
        "${runlevel}-cleanup":
            content  => template("${module_name}/tasks/cleanup.erb");
    }
}
