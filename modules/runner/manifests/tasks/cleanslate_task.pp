# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
class runner::tasks::cleanslate_task($runlevel=1) {
    include runner
    include cleanslate
    include buildslave::install

    runner::task {
        "${runlevel}-cleanslate":
            require => [
                Class['cleanslate'],
                Class['buildslave::install']
            ],
            content => template("${module_name}/tasks/cleanslate.erb");
    }
}
