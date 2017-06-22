# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.

class runner::tasks::halt() {
    include runner

    case $::operatingsystem {
        'Windows': {
            runner::task {
                'halt.bat':
                    source => 'puppet:///modules/runner/tasks/halt.bat';
            }
        }
        default: {
            runner::task {
                'halt.py':
                    content  => template("${module_name}/tasks/halt.py.erb");
            }
        }
    }
}
