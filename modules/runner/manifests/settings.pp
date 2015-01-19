# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
# settings for runner
class runner::settings {
    case $::operatingsystem {
        'CentOS', 'Ubuntu', 'Darwin': {
            $root = '/opt/runner'
            $task_hook = "${root}/task_hook.py"
        }
        'Windows': {
            $root = "c:/opt/runner"
            $task_hook = "${root}/task_hook.py"
            # windows needs an interpreter specified to work properly
            $interpreter = "python"
        }
        default: {
            fail("Unsupported OS ${::operatingsystem}")
        }
    }
    # leaving out the interpreter causes failures on windows while including
    # it works everywhere (windows does not support hash bangs)
    $task_hook_cmd = "python ${task_hook}"
    $taskdir = "${root}/tasks.d"
    $configdir = "${root}/config.d"
}
